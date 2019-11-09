module Spree::Chimpy
  module Interface
    class CustomerUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      attr_reader :order
      def initialize(order)
        @order = order
      end

      # CUSTOMER will be pulled first from the MC_EID if present on the
      # order.source
      # IF that is not found, customer will be found by our Customer ID assuming
      # there is a user on the order, and their id is `customer_#{user.id}`.
      # If that is not found, customer is searched via email address
      # IF that is not found, customer is created with the order email and our
      # Customer ID, or guest_id
      def ensure_customer
        lookup_customer_id_from_eid ||
          lookup_customer_id_from_user_id ||
          lookup_customer_id_from_email_address ||
          upsert_customer
      end

      def lookup_customer_id_from_eid
        return unless order.source.try(:email_id)

        email = Spree::Chimpy.list.email_for_id(order.source.email_id)
        lookup_email_address email if email
      end

      def lookup_customer_id_from_user_id(user_id)
        mailchimp_customer_id = customer_id_from_user_id user_id
        begin
          response = store_api_call.
            customer(mailchimp_customer_id).
            retrieve(params: { "fields" => "customers.id" })

          data = response["customers"].first
          data["id"] if data
        rescue Gibbon::MailChimpError => _e
          nil
        end
      end

      def lookup_customer_id_from_email_address
        lookup_email_address order.email
      end

      private

      def lookup_email_address(email_address)
        response = store_api_call.
          customers.
          retrieve params: \
            { "fields" => "customers.id", "email_address" => email_address }

        data = response["customers"].first
        data["id"] if data
      rescue Gibbon::MailChimpError => _e
        nil
      end

      def customer_id_from_user_id(user_id)
        "customer_#{user_id}"
      end

      def mailchimp_customer_id
        if order.user_id.present?
          customer_id_from_user_id(order.user_id)
        else
          "guest_#{Digest::MD5.hexdigest email_from_order}"
        end
      end

      def email_from_order
        order.email.downcase
      end

      def first_name_from_order
        order.name.split(" ").first
      end

      def last_name_from_order
        order.name.split(" ")[1..-1].join(" ")
      end

      def upsert_customer
        customer_id = mailchimp_customer_id
        email = email_from_order

        begin
          store_api_call.customers(customer_id).upsert body:
            {
              email_address: email,
              first_name: first_name_from_order,
              last_name: last_name_from_order,
              opt_in_status: Spree::Chimpy::Config.subscribe_to_list || false,
            }

          customer_id
        rescue Gibbon::MailChimpError => e
          log "failed to create customer:#{customer_id} with email: #{email}..."
          log e
          nil
        end
      end
    end
  end
end
