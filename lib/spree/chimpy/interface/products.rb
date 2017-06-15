module Spree::Chimpy
  module Interface
    class Products
      delegate :log, :store_api_call, to: Spree::Chimpy
      include Rails.application.routes.url_helpers

      def initialize(variant)
        @variant = variant
        @product = variant.product
      end

      def self.mailchimp_variant_id(variant)
        variant.id.to_s
      end

      def self.mailchimp_product_id(variant)
        variant.product_id.to_s
      end

      def self.ensure_products(order)
        order.line_items.each do |line|
          new(line.variant).ensure_product
        end
      end

      def ensure_product
        if product_exists_in_mailchimp?
          upsert_variants
        else
          store_api_call
            .products
            .create(body: product_hash)
        end
      end

      private

      def upsert_variants
        all_variants = @product.variants.any? ? @product.variants : [@product.master]
        all_variants.each do |v|
          data = self.class.variant_hash(v)
          data.delete(:id)

          store_api_call
            .products(v.product_id)
            .variants(v.id)
            .upsert(body: data)
        end
      end

      def product_exists_in_mailchimp?
        response = store_api_call
          .products(@variant.product.id)
          .retrieve(params: { "fields" => "id" })
        !response["id"].nil?
      rescue Gibbon::MailChimpError => e
        false
      end

      def product_hash
        root_taxon = Spree::Taxon.where(parent_id: nil).take
        taxon = @product.taxons.map(&:self_and_ancestors).flatten.uniq.detect { |t| t.parent == root_taxon }

        # assign a default taxon if the product is not associated with a category
        taxon = root_taxon if taxon.blank?

        all_variants = @product.variants.any? ? @product.variants : [@product.master]
        data = {
          id: self.class.mailchimp_product_id(@variant),
          title: @product.name,
          handle: @product.slug,
          url: self.class.product_url_or_default(@product),
          variants: all_variants.map { |v| self.class.variant_hash(v) },
          type: taxon.name
        }

        if @product.images.any?
          data[:image_url] = @product.images.first.attachment.url(:product).to_s
        end

        if @product.respond_to?(:available_on) && @product.available_on
          data[:published_at_foreign] = @product.available_on.to_formatted_s(:db)
        end
        data
      end

      def self.variant_hash(variant)
        {
          id: mailchimp_variant_id(variant),
          title: variant.name,
          sku: variant.sku,
          url: product_url_or_default(variant.product),
          price: variant.price.to_f,
          image_url: variant_image_url(variant).to_s,
          inventory_quantity: variant.total_on_hand == Float::INFINITY ? 999 : variant.total_on_hand
        }
      end

      def self.variant_image_url(variant)
        if variant.images.any?
          variant.images.first.attachment.url(:product)
        elsif variant.product.images.any?
          variant.product.images.first.attachment.url(:product)
        end
      end

      def self.product_url_or_default(product)
        if self.respond_to?(:product_url)
          product_url(product)
        else
          URI::HTTP.build({
            host: Rails.application.routes.default_url_options[:host],
            :path => "/products/#{product.slug}"}
          ).to_s
        end
      end
    end
  end
end
