module SpreeHominid
  class Interface
    API_VERSION = '1.3'

    def initialize(key, list_name)
      @api       = Hominid::API.new(key, api_version: API_VERSION)
      @list_name = list_name
    end

    def subscribe(email, merge_vars = {})
      log "Subscribing #{email} to #{@list_name}"

      @api.list_subscribe(list_id, email, merge_vars, update_existing: true)
    end

    def unsubscribe(email)
      log "Unsubscribing #{email} from #{@list_name}"

      @api.list_unsubscribe(list_id, email)
    end

    def merge_vars
      log "Finding merge vars for #{@list_name}"

      @api.list_merge_vars(list_id).map {|record| record['tag'] }
    end

    def add_merge_var(tag, description)
      log "Adding merge var #{tag} to #{@list_name}"

      @api.list_merge_var_add(list_id, tag, description)
    end

    def find_list_id(name)
      @api.find_list_id_by_name(name)
    end

    def list_id
      @list_id ||= find_list_id(@list_name)
    end

    def add_order(order, email_id=nil)
      items = order.line_items.map do |line|
        variant = line.variant

        {product_id:   variant.id,
         sku:          variant.sku,
         product_name: variant.name,
         cost:         variant.cost_price,
         qty:          line.quantity}
      end

      @api.ecomm_order_add(id:         order.number,
                           email_id:   email_id,
                           email:      order.email,
                           total:      order.total,
                           order_date: order.completed_at,
                           shipping:   order.ship_total,
                           tax:        order.tax_total,
                           store_name: Spree::Config.preferred_site_name,
                           store_id:   SpreeHominid::Config.preferred_store_id,
                           items:      items)
    end

    def remove_order(order)
      @api.ecomm_order_del(Config.preferred_store_id, order.number)
    end

  private
    def log(message)
      Rails.logger.info "MAILCHIMP: #{message}"
    end
  end
end
