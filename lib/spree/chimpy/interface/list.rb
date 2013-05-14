module Spree::Chimpy
  module Interface
    class List
      API_VERSION = '1.3'

      def initialize(key, list_name, segment_name)
        @api       = Hominid::API.new(key, api_version: API_VERSION)
        @list_name = list_name
        @segment_name = segment_name
      end

      def subscribe(email, merge_vars = {})
        log "Subscribing #{email} to #{@list_name}"

        @api.list_subscribe(list_id, email, merge_vars, update_existing = true)
      end

      def segment_emails(emails)
        @api.list_static_segment_members_add(list_id, static_segment_id, emails)
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
      
      def find_or_create_static_segment(segment_name)
        static_segments = @api.list_static_segments(list_id)
        static_segments.each do |segment|
          if segment['name'] == segment_name
            @segment_id = segment['id']
            break
          end
        end
        if @segment_id.nil?
          create_static_segment_by_name(segment_name) if @segment_id.nil?
        end
        @segment_id
      end
      
      def create_static_segment_by_name(segment_name)
        @api.list_static_segments_add(list_id, segment_name)
      end
      
      def static_segment_id(segment_name)
        @static_segment_id ||= find_or_create_static_segment(segment_name)
      end

    private
      def log(message)
        Rails.logger.info "MAILCHIMP: #{message}"
      end
    end
  end
end
