module Spree::Chimpy
  module Interface
    class CartUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize(cart)
        @cart = cart
      end

      def customer_id
        @customer_id ||= CustomerUpserter.new(@cart).ensure_customer
      end

      def upsert
        return unless customer_id

        Products.ensure_products(@cart)

        perform_upsert
      end

      private

      def perform_upsert
        data = cart_hash
        log "Adding cart #{@cart.number} for #{data[:customer][:id]} with campaign #{data[:campaign_id]}"
        begin
          find_and_update_cart(data)
        rescue Gibbon::MailChimpError => e
          log "Cart #{@cart.number} Not Found, creating cart"
          create_cart(data)
        end
      end

      def find_and_update_cart(data)
        # retrieval is checks if the order exists and raises a Gibbon::MailChimpError when not found
        response = store_api_call.carts(@cart.number).retrieve(params: { "fields" => "id" })
        log "Cart #{@cart.number} exists, updating data"
        store_api_call.carts(@cart.number).update(body: data)
      end

      def create_cart(data)
        store_api_call
          .carts
          .create(body: data)
      rescue Gibbon::MailChimpError => e
        log "Unable to create cart #{@cart.number}. [#{e.raw_body}]"
      end

      def cart_variant_hash(line_item)
        variant = line_item.variant
        {
          id: "line_item_#{line_item.id}",
          product_id:    Products.mailchimp_product_id(variant),
          product_variant_id: Products.mailchimp_variant_id(variant),
          price:          variant.price.to_f,
          quantity:           line_item.quantity
        }
      end

      def cart_hash
        source = @cart.source

        lines = @cart.line_items.map do |line|
          # MC can only associate the order with a single category: associate the order with the category right below the root level taxon
          cart_variant_hash(line)
        end

        data = {
          id:                @cart.number,
          checkout_url:      "https://www.sweetist.com/checkout",
          lines:             lines,
          order_total:       @cart.total.to_f,
          financial_status:  @cart.payment_state || "",
          fulfillment_status: @cart.shipment_state || "",
          currency_code:     @cart.currency,
          processed_at_foreign:  @cart.completed_at ? @cart.completed_at.to_formatted_s(:db) : "",
          updated_at_foreign: @cart.updated_at.to_formatted_s(:db),
          shipping_total:    @cart.ship_total.to_f,
          tax_total:         @cart.try(:included_tax_total).to_f + @cart.try(:additional_tax_total).to_f,
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
