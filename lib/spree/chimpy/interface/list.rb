module Spree::Chimpy
  module Interface
    class List
      delegate :log, to: Spree::Chimpy

      def initialize(list_name, segment_name, double_opt_in)
        @api           = Spree::Chimpy.api
        @list_name     = list_name
        @segment_name  = segment_name
        @double_opt_in = double_opt_in
      end

      def subscribe(email, merge_vars = {}, options = {})
        log "Subscribing #{email} to #{@list_name}"
        member = @api.lists.member_info(list_id, [{email: email}])
        # returning if the user was found, but is not subscribed, 
        # then we update our information and do not subscribe them again.
        if member && member['success_count'] == 1
          if member['data'][0]['status'] != 'subscribed'
            user = Spree.user_class.where(email: email, subscribed: true).first
            user.update_column(:subscribed, false) if user
            return
          end
        end

        update_existing = true
        begin
          @api.lists.subscribe(list_id, {email: email}, merge_vars, 'html', @double_opt_in, update_existing)
          segment([email]) if options[:customer]
        rescue Mailchimp::ListInvalidImportError => e
          Rails.logger.error("spree_chimpy: Error in subscribing email: #{email} - #{e.inspect}")
        end

      end

      def batch_subscribe(email_batch)
        log "Batch subscribing to #{@list_name}"
        update_existing = true

        @api.lists.batch_subscribe(list_id, email_batch, @double_opt_in, update_existing)
      end

      def unsubscribe(email)
        log "Unsubscribing #{email} from #{@list_name}"

        @api.lists.unsubscribe(list_id, {email: email})
      end

      def merge_vars
        log "Finding merge vars for #{@list_name}"

        result = @api.lists.merge_vars(Array(list_id))
        result['data'][0]['merge_vars'].map { |record| record['tag'] }
      end

      def add_merge_var(tag, description)
        log "Adding merge var #{tag} to #{@list_name}"

        @api.lists.merge_var_add(list_id, tag, description)
      end

      def find_list_id(name)
        lists_res = @api.lists.list({'list_name' => name})
        selected_list = lists_res['data'].select { |list_data| list_data["name"] == name }
        selected_list.first["id"]
      end

      def list_id
        @list_id ||= find_list_id(@list_name)
      end

      def segment(emails = [])
        log "Adding #{emails} to segment #{@segment_name}"
        emails = emails.map {|email| {email: email} }
        @api.lists.static_segment_members_add(list_id, segment_id, emails)
      end

      def create_segment
        log "Creating segment #{@segment_name}"

        @segment_id = @api.lists.segment_add(list_id, {type: 'static', name: @segment_name})['id']
      end

      def find_segment_id
        segments = @api.lists.segments(list_id, 'static')
        segment  = segments['static'].detect {|segment| segment['name'].downcase == @segment_name.downcase }

        if segment.blank?
          create_segment
        else
          segment['id']
        end
      end

      def segment_id
        @segment_id ||= find_segment_id
      end
    end
  end
end
