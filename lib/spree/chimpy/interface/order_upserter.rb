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
        data = order_hash
        log "Adding order #{@order.number} for #{data[:customer][:id]} with campaign #{data[:campaign_id]}"
        begin
          find_and_update_order(data)
        rescue Gibbon::MailChimpError => e
          log "Order #{@order.number} Not Found, creating order"
          create_order(data)
        end
      end

      def find_and_update_order(data)
        # retrieval is checks if the order exists and raises a Gibbon::MailChimpError when not found
        response = store_api_call.orders(@order.number).retrieve(params: { "fields" => "id" })
        log "Order #{@order.number} exists, updating data"
        store_api_call.orders(@order.number).update(body: data)
      end

      def create_order(data)
        store_api_call
          .orders
          .create(body: data)
      rescue Gibbon::MailChimpError => e
        log "Unable to create order #{@order.number}. [#{e.raw_body}]"
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

        lines = @order.line_items.map do |line|
          # MC can only associate the order with a single category: associate the order with the category right below the root level taxon
          order_variant_hash(line)
        end

        data = {
          id:                @order.number,
          lines:             lines,
          order_total:       @order.total.to_f,
          financial_status:  @order.payment_state || "",
          fulfillment_status: @order.shipment_state || "",
          currency_code:     @order.currency,
          processed_at_foreign:  @order.completed_at ? @order.completed_at.to_formatted_s(:db) : "",
          updated_at_foreign: @order.updated_at.to_formatted_s(:db),
          cancelled_at_foreign: @order.canceled_at ? @order.canceled_at.to_formatted_s(:db) : "",
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
    end
  end
end
