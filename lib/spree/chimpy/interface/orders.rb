module Spree::Chimpy
  module Interface
    class Orders
      NOT_FOUND_FAULT = 330

      delegate :log, to: Spree::Chimpy

      def initialize(key)
        @api = Hominid::API.new(key, api_version: Spree::Chimpy::API_VERSION)
      end

      def add(order)
        log "Adding order #{order.number}"

        @api.ecomm_order_add(hash(order))
      end

      def remove(order)
        log "Attempting to remove order #{order.number}"

        begin
          @api.ecomm_order_del(Config.store_id, order.number)
        rescue Hominid::APIError => e
          raise(e) unless e.fault_code == NOT_FOUND_FAULT
        end
      end

      def sync(order)
        remove(order)
        add(order)
      end

    private
      def hash(order)
        source = order.source

        items = order.line_items.map do |line|
          variant = line.variant
          ptaxon = Spree::Taxonomy.find_by_name("Categories")
          taxon_id = variant.product.taxons.where(:parent_id => ptaxon.id).uniq.map(&:id).first
          taxon_name = variant.product.taxons.where(:id => taxon_id).uniq.map(&:name).first

          {product_id:    variant.id,
           sku:           variant.sku,
           product_name:  variant.name,
           category_id:   taxon_id,
           category_name: taxon_name,
           cost:          variant.cost_price.to_f,
           qty:           line.quantity}
        end

        data = {
          id:          order.number,
          email:       order.email,
          total:       order.total.to_f,
          order_date:  order.completed_at,
          shipping:    order.ship_total.to_f,
          tax:         order.tax_total.to_f,
          store_name:  Spree::Config.site_name,
          store_id:    Spree::Chimpy::Config.store_id,
          items:       items
        }

        if source
          data[:email_id]    = source.email_id
          data[:campaign_id] = source.campaign_id
        end

        data
      end

    end
  end
end
