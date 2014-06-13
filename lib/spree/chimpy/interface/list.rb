module Spree::Chimpy
  module Interface
    class List
      delegate :log, to: Spree::Chimpy

      def initialize(list_name, segment_name, double_opt_in, list_id)
        @api           = Spree::Chimpy.api
        @list_id       = list_id
        @segment_name  = segment_name
        @double_opt_in = double_opt_in
        @list_name     = list_name
      end

      def subscribe(email, merge_vars = {}, options = {})
        log "Subscribing #{email} to #{@list_name}"

        @api.list_subscribe(id: list_id, email_address: email, merge_vars: merge_vars, update_existing: true, double_optin: @double_opt_in, email_type: 'html')

        segment([email]) if options[:customer]
      end

      def unsubscribe(email)
        log "Unsubscribing #{email} from #{@list_name}"

        @api.list_unsubscribe(id: list_id, email_address: email)
      end

      def info(email_or_id)
        log "Checking member info for #{email_or_id} from #{@list_name}"

        response = @api.list_member_info(id: list_id, email_address: email_or_id)
        record = response['data'].first.symbolize_keys

        record.key?(:error) ? {} : record
      end

      def merge_vars
        log "Finding merge vars for #{@list_name}"

        @api.list_merge_vars(id: list_id).map { |record| record['tag'] }
      end

      def add_merge_var(tag, description)
        log "Adding merge var #{tag} to #{@list_name}"

        @api.list_merge_var_add(id: list_id, tag: tag, name: description)
      end

      def find_list_id(name)
        @api.lists["data"].detect { |r| r["name"] == name }["id"]
      end

      def list_id
        @list_id ||= find_list_id(@list_name)
      end

      def segment(emails = [])
        log "Adding #{emails} to segment #{@segment_name}"

        @api.list_static_segment_members_add(id: list_id, seg_id: segment_id, batch: emails)
      end

      def create_segment
        log "Creating segment #{@segment_name}"

        @segment_id = @api.list_static_segment_add(id: list_id, name: @segment_name)
      end

      def find_segment_id
        segments = @api.list_static_segments(id: list_id)
        segment  = segments.detect {|segment| segment['name'].downcase == @segment_name.downcase }

        segment['id'] if segment
      end

      def segment_id
        @segment_id ||= find_segment_id
      end
    end
  end
end
