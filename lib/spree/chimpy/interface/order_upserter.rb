module Spree::Chimpy
  module Interface
    class OrderUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize(order)
        @order = order
      end

      def customer_id
        @customer_id ||= CustomerUpserter.new(@order).ensure_customer
      end

      def upsert
        return unless customer_id

        Products.ensure_products(@order)

        perform_upsert
      end

      private

      def perform_upsert
        data = api_data
        log "Adding order/cart #{@order.number} for #{data[:customer][:id]} with campaign #{data[:campaign_id]}"
        begin
          find_and_update_order(data)
        rescue Gibbon::MailChimpError => e
          log "Order #{@order.number} Not Found, creating order"
          create_order(data)
        end
      end

      def api_data
        return cart_hash if @order.state != 'complete'
        order_hash
      end

      def find_and_update_order(data)
        # retrieval is checks if the order exists and raises a Gibbon::MailChimpError when not found
        if @order.state != 'complete'
          store_api_call.carts(@order.number).retrieve(params: { "fields" => "id" })
          log "Cart #{@order.number} exists, updating data"
          if @order.reload.line_items.empty?
            remove_cart_from_mailchimp if cart_exist?
          else
            store_api_call.carts(@order.number).update(body: data)
          end
        else
          store_api_call.orders(@order.number).retrieve(params: { "fields" => "id" })
          log "Order #{@order.number} exists, updating data"
          store_api_call.orders(@order.number).update(body: data)
        end
      end

      def create_order(data)
        if @order.state != 'complete'
          url = store_api_call.carts
        else
          url = store_api_call.orders
          remove_cart_from_mailchimp if cart_exist?
          CustomerUpserter.new(@order).ensure_customer
        end
        url.create(body: data)
      rescue Gibbon::MailChimpError => e
        log "Unable to create cart/order #{@order.number}. [#{e.raw_body}]"
      end

      def cart_exist?
        begin
          response = store_api_call
            .carts(@order.number)
            .retrieve(params: { "fields" => "id" })
          !response["id"].nil?
        rescue Gibbon::MailChimpError => e
          log "Cart #{@order.number} Not Found"
          false
        end
      end

      def remove_cart_from_mailchimp
        response = store_api_call
                    .carts(@order.number).delete
      end

      def order_variant_hash(line_item)
        variant = line_item.variant
        {
          id: "line_item_#{line_item.id}",
          product_id:    Products.mailchimp_product_id(variant),
          product_variant_id: Products.mailchimp_variant_id(variant),
          price:          variant.price.to_f,
          quantity:           line_item.quantity
        }
      end

      def order_hash
        source = @order.source

        data = {
          id:                @order.number,
          lines:             order_lines,
          order_total:       @order.total.to_f,
          financial_status:  @order.payment_state || "",
          fulfillment_status: @order.shipment_state || "",
          currency_code:     @order.currency,
          processed_at_foreign:  @order.completed_at ? @order.completed_at.to_formatted_s(:db) : "",
          updated_at_foreign: @order.updated_at.to_formatted_s(:db),
          shipping_total:    @order.ship_total.to_f,
          tax_total:         @order.try(:included_tax_total).to_f + @order.try(:additional_tax_total).to_f,
          customer: {
            id: customer_id
          }
        }

        if source
          data[:campaign_id] = source.campaign_id
        end

        data
      end

      def order_lines
        @order.line_items.map do |line|
          # MC can only associate the order with a single category: associate the order with the category right below the root level taxon
          order_variant_hash(line)
        end
      end

      def cart_hash
        source = @order.source
        data = {
          id:                @order.number,
          lines:             order_lines,
          order_total:       @order.total.to_f,
          currency_code:     @order.currency,
          tax_total:         @order.try(:included_tax_total).to_f + @order.try(:additional_tax_total).to_f,
          checkout_url: checkout_url,
          customer: {
            id: customer_id
          }
        }

        if source
          data[:campaign_id] = source.campaign_id
        end

        data
      end

      def checkout_url
        URI::HTTP.build({
          host: Rails.application.routes.default_url_options[:host],
          :path => "/cart"}
        ).to_s
      end
    end
  end
end
