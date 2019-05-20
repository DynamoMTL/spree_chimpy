require 'digest'

module Spree::Chimpy
  module Interface
    class List
      delegate :log, :segment_enabled?, to: Spree::Chimpy

      def initialize(list_name, segment_name, double_opt_in, send_welcome_email, list_id)
        @list_id       = list_id
        @segment_name  = segment_name
        @double_opt_in = double_opt_in
        @send_welcome_email = send_welcome_email
        @list_name     = list_name
      end

      def api_call(list_id = nil)
        if list_id
          Spree::Chimpy.api.lists(list_id)
        else
          Spree::Chimpy.api.lists
        end
      end

      def subscribe(email, merge_vars = {}, options = {})
        log "Subscribing #{email} to #{@list_name}"

        begin
          api_member_call(email)
            .upsert(body: {
              email_address: email,
              status: "subscribed",
              merge_fields: merge_vars,
              email_type: 'html'
            }) #, @double_opt_in, true, true, @send_welcome_email)

          segment([email]) if options[:customer]
        rescue Gibbon::MailChimpError => ex
          log "Subscriber #{email} rejected for reason: [#{ex.raw_body}]"
          true
        end
      end

      def unsubscribe(email)
        log "Unsubscribing #{email} from #{@list_name}"

        begin
          api_member_call(email)
            .update(body: {
              email_address: email,
              status: "unsubscribed"
            })
        rescue Gibbon::MailChimpError => ex
          log "Subscriber unsubscribe for #{email} failed for reason: [#{ex.raw_body}]"
          true
        end
      end

      def email_for_id(mc_eid)
        log "Checking customer id for #{mc_eid} from #{@list_name}"
        begin
          response = api_list_call
            .members
            .retrieve(params: { "unique_email_id" => mc_eid, "fields" => "members.id,members.email_address" })

          member_data = response["members"].first
          member_data["email_address"] if member_data
        rescue Gibbon::MailChimpError => ex
          nil
        end
      end

      def info(email)
        log "Checking member info for #{email} from #{@list_name}"

        #maximum of 50 emails allowed to be passed in
        begin
          response = api_member_call(email)
            .retrieve(params: { "fields" => "email_address,merge_fields,status"})

          response = response.symbolize_keys
          response.merge(email: response[:email_address])
        rescue Gibbon::MailChimpError
          {}
        end

      end

      def merge_vars
        log "Finding merge vars for #{@list_name}"

        response = api_list_call
          .merge_fields
          .retrieve(params: { "fields" => "merge_fields.tag,merge_fields.name"})
        response["merge_fields"].map { |record| record['tag'] }
      end

      def add_merge_var(tag, description)
        log "Adding merge var #{tag} to #{@list_name}"

        api_list_call
          .merge_fields
          .create(body: {
            tag: tag,
            name: description,
            type: "text"
          })
      end

      def find_list_id(name)
        response = api_call
          .retrieve(params: {"fields" => "lists.id,lists.name"})
        list = response["lists"].detect { |r| r["name"] == name }
        list["id"] if list
      end

      def list_id
        @list_id ||= find_list_id(@list_name)
      end

      def segment(emails = [])
        return unless segment_enabled?

        log "Adding #{emails} to segment #{@segment_name} [#{segment_id}] in list [#{list_id}]"

        api_list_call.segments(segment_id.to_i).create(body: { members_to_add: Array(emails) })
      end

      def create_segment
        log "Creating segment #{@segment_name}"

        result = api_list_call.segments.create(body: { name: @segment_name, static_segment: []})
        @segment_id = result["id"]
      end

      def find_segment_id
        response = api_list_call
          .segments
          .retrieve(params: {"fields" => "segments.id,segments.name"})
        segment = response["segments"].detect {|segment| segment['name'].downcase == @segment_name.downcase }

        segment['id'] if segment
      end

      def segment_id
        @segment_id ||= find_segment_id
      end

      def api_list_call
        api_call(list_id)
      end

      def api_member_call(email)
        api_list_call.members(email_to_lower_md5(email))
      end

      private

      def email_to_lower_md5(email)
        Digest::MD5.hexdigest(email.downcase)
      end
    end
  end
end
