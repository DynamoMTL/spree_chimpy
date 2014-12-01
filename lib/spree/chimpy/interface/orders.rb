module Spree::Chimpy
  module Interface
    class Orders
      delegate :log, to: Spree::Chimpy

      def initialize
        @api = Spree::Chimpy.api
      end

      def api_call
        @api.ecomm
      end

      def add(order)
        if source = order.source
          info = Spree::Chimpy.list.info(source.email_id)
          # use the one from mail chimp or fall back to the order's email
          # happens when this is a new user
          expected_email = (info[:email] || order.email).to_s
        else
          expected_email = order.email
        end

        # create the user if it does not exist yet
        if Spree::Chimpy::Config.subscribe_to_list
          log "Subscribing #{expected_email} to list"
          Spree::Chimpy.list.subscribe(expected_email)
        end

        data = hash(order, expected_email)
        log "Adding order #{order.number} for #{expected_email} with campaign #{data[:campaign_id]}"
        begin
          api_call.order_add(data)
        rescue Mailchimp::EmailNotExistsError => e
          if source
            log "invalid eid (#{source.email_id}) for email #{expected_email} [#{e.message}]"
          else
            log "invalid email #{expected_email} [#{e.message}]"
          end
        end
      end

      def remove(order)
        log "Attempting to remove order #{order.number}"

        begin
          api_call.order_del(Spree::Chimpy::Config.store_id, order.number)
        rescue => e
          log "error removing #{order.number} | #{e}"
        end
      end

      def sync(order)
        add(order)
      rescue Mailchimp::InvalidEcommOrderError => e
        log "invalid ecomm order error [#{e.message}]"
      end

    private
      def hash(order, expected_email)
        source = order.source
        root_taxon = Spree::Taxon.where(parent_id: nil).take

        items = order.line_items.map do |line|
          # MC can only associate the order with a single category: associate the order with the category right below the root level taxon
          variant = line.variant
          taxon = variant.product.taxons.map(&:self_and_ancestors).flatten.uniq.detect { |t| t.parent == root_taxon }

          # assign a default taxon if the product is not associated with a category
          taxon = root_taxon if taxon.blank?

          {product_id:    variant.id,
           sku:           variant.sku,
           product_name:  variant.name,
           category_id:   taxon ? taxon.id : 999999,
           category_name: taxon ? taxon.name : Spree.t(:uncategorized, scope: :chimpy, default: 'Uncategorized'),
           cost:          variant.price.to_f,
           qty:           line.quantity}
        end

        data = {
          id:          order.number,
          email:       order.email,
          total:       order.total.to_f,
          order_date:  order.completed_at ? order.completed_at.to_formatted_s(:db) : nil,
          shipping:    order.ship_total.to_f,
          tax:         order.try(:included_tax_total).to_f, # or additional_tax_total
          store_name:  Spree::Chimpy::Config.store_id.titleize,
          store_id:    Spree::Chimpy::Config.store_id,
          items:       items
        }

        if source && expected_email.upcase == order.email.upcase
          data[:email_id]    = source.email_id
          data[:campaign_id] = source.campaign_id
        end
        data
      end

    end
  end
end
