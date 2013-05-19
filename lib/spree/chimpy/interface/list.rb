module Spree::Chimpy
  module Interface
    class List
      delegate :log, to: Spree::Chimpy

      def initialize(key, list_name, segment_name)
        @api          = Hominid::API.new(key, api_version: Spree::Chimpy::API_VERSION)
        @list_name    = list_name
        @segment_name = segment_name
      end

      def subscribe(email, merge_vars = {}, options = {})
        log "Subscribing #{email} to #{@list_name}"

        @api.list_subscribe(list_id, email, merge_vars, 'html', true, true)

        segment(email) if options[:customer]
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

      def list_id
        @list_id ||= @api.find_list_id_by_name(@list_name)
      end

      def segment(email)
        log "Adding #{email} to segment #{@segment_name}"

        @api.list_static_segment_members_add(list_id, segment_id, [email])
      end

      def create_segment
        log "Creating segment #{@segment_name}"

        @segment_id = @api.list_static_segment_add(list_id, @segment_name)
      end

      def find_segment_id
        segments = @api.list_static_segments(list_id)
        segment  = segments.detect {|segment| segment['name'].downcase == @segment_name.downcase }

        segment['id'] if segment
      end

      def segment_id
        @segment_id ||= find_segment_id
      end
    end
  end
end
