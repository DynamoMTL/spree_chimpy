module SpreeHominid
  class Interface
    API_VERSION = '1.3'

    def initialize(key)
      @api = Hominid::API.new(key, api_version: API_VERSION)
    end

    def subscribe(list_name, email)
      log "Subscribing #{email} to #{list_name}"

      list_id = find_list_id(list_name)
      @api.list_subscribe(list_id, email, update_existing: true)
    end

    def unsubscribe(list_name, email)
      log "Unsubscribing #{email} from #{list_name}"

      list_id = find_list_id(list_name)
      @api.list_unsubscribe(list_id, email)
    end

    def merge_vars(list_name)
      log "Finding merge vars for #{list_name}"

      list_id = find_list_id(list_name)
      @api.list_merge_vars(list_id).map {|record| record['tag'] }
    end

    def find_list_id(name)
      @api.find_list_id_by_name(name)
    end

  private
    def log(message)
      Rails.logger.info "MAILCHIMP: #{message}"
    end
  end
end
