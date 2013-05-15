module Spree::Chimpy
  module Interface
    class List
      delegate :log, to: Spree::Chimpy

      def initialize(key, list_name)
        @api       = Hominid::API.new(key, api_version: Spree::Chimpy::API_VERSION)
        @list_name = list_name
      end

      def subscribe(email, merge_vars = {})
        log "Subscribing #{email} to #{@list_name}"

        @api.list_subscribe(list_id, email, merge_vars, 'html', true, true)
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
    end
  end
end
