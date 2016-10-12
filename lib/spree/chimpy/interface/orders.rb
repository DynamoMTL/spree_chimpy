module Spree::Chimpy
  module Interface
    class Orders
      include Rails.application.routes.url_helpers
      delegate :log, to: Spree::Chimpy

      def initialize
      end

      def api_call
        Spree::Chimpy.api.ecommerce.stores(Spree::Chimpy::Config.store_id)
      end

      def add(order)
        if source = order.source
          # use the one from mail chimp or fall back to the order's email
          # happens when this is a new user
          expected_email = (Spree::Chimpy.list.email_for_id(source.email_id) || order.email).to_s
        else
          expected_email = order.email
        end

        ensure_products(order)
        data = hash(order, expected_email)
        log "Adding order #{order.number} for #{expected_email} with campaign #{data[:campaign_id]}"
        begin
          api_call.orders(order.number).upsert(body: data)
        rescue Gibbon::MailChimpError => e
          if source
            log "invalid eid (#{source.email_id}) for email #{expected_email} [#{e.raw_body}]"
          else
            log "invalid email #{expected_email} [#{e.raw_body}]"
          end
        end
      end

      def remove(order)
        log "Attempting to remove order #{order.number}"

        begin
          api_call.orders(order.number).delete
        rescue Gibbon::MailChimpError => e
          log "error removing #{order.number} | #{e.raw_body}"
        end
      end

      def sync(order)
        add(order)
      rescue Gibbon::MailChimpError => e
        log "invalid ecomm order error [#{e.raw_body}]"
      end

    private

      def ensure_products(order)
        order.line_items.map do |line|
          ensure_product(line.variant)
        end
      end

      def product_exists_in_mailchimp?(product)
        response = api_call
          .products(product.id)
          .retrieve(params: { "fields" => "id" })
        !response["id"].nil?
      rescue Gibbon::MailChimpError => e
        false
      end

      def ensure_product(variant)
        product = variant.product
        if product_exists_in_mailchimp?(product)
          upsert_variants(product)
        else
          api_call
            .products
            .create(body: product_hash(variant))
        end
      end

      def upsert_variants(product)
        all_variants = product.variants.any? ? product.variants : [product.master]
        all_variants.each do |v|
          data = variant_hash(v)
          data.delete(:id)

          api_call
            .products(v.product_id)
            .variants(v.id)
            .upsert(body: data)
        end
      end

      def product_hash(variant)
        product = variant.product

        root_taxon = Spree::Taxon.where(parent_id: nil).take
        taxon = variant.product.taxons.map(&:self_and_ancestors).flatten.uniq.detect { |t| t.parent == root_taxon }

        # assign a default taxon if the product is not associated with a category
        taxon = root_taxon if taxon.blank?


        all_variants = product.variants.any? ? product.variants : [product.master]
        data = {
          id: product.id.to_s,
          title: product.name,
          handle: product.slug,
          url: product_url_or_default(variant.product),
          variants: all_variants.map { |v| variant_hash(v) },
          type: taxon.name
        }

        if product.images.any?
          data[:image_url] = product.images.first.attachment.url(:product)
        end

        if product.respond_to?(:available_on) && product.available_on
          data[:published_at_foreign] = product.available_on.to_formatted_s(:db)
        end
        data
      end

      def variant_hash(variant)
        {
          id: variant.id.to_s,
          title: variant.name,
          sku: variant.sku,
          url: product_url_or_default(variant.product),
          price: variant.price.to_f,
          image_url: variant_image_url(variant),
          inventory_quantity: variant.total_on_hand == Float::INFINITY ? 999 : variant.total_on_hand
        }
      end

      def variant_image_url(variant)
        if variant.images.any?
          variant.images.first.attachment.url(:product)
        elsif variant.product.images.any?
          variant.product.images.first.attachment.url(:product)
        end
      end

      def product_url_or_default(product)
        if self.respond_to?(:product_url)
          product_url(product)
        else
          URI::HTTP.build({
            host: Rails.application.routes.default_url_options[:host],
            :path => "/products/#{product.slug}"}
          ).to_s
        end
      end

      def hash(order, expected_email)
        source = order.source

        lines = order.line_items.map do |line|
          # MC can only associate the order with a single category: associate the order with the category right below the root level taxon
          variant = line.variant

          {
            id: "line_item_#{line.id}",
            product_id:    variant.product_id,
            product_variant_id: variant.id,
            price:          variant.price.to_f,
            quantity:           line.quantity
          }
        end

        data = {
          id:                order.number,
          lines:             lines,
          order_total:       order.total.to_f,
          financial_status:  order.payment_state,
          fulfillment_status: order.shipment_state,
          currency_code:     order.currency,
          processed_at_foreign:  order.completed_at ? order.completed_at.to_formatted_s(:db) : nil,
          updated_at_foreign: order.updated_at.to_formatted_s(:db),
          shipping_total:    order.ship_total.to_f,
          tax_total:         order.try(:included_tax_total).to_f + order.try(:additional_tax_total).to_f,
        }

        if source && expected_email.upcase == order.email.upcase
          data[:email_id]    = source.email_id
          data[:campaign_id] = source.campaign_id
        end

        data[:customer] = {
          id: "customer_#{order.user_id}",
          email_address: order.email.downcase,
          opt_in_status: Spree::Chimpy::Config.subscribe_to_list || false
        }

        data
      end

    end
  end
end
