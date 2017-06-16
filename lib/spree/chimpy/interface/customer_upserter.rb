module Spree::Chimpy
  module Interface
    class CustomerUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize(order)
        @order = order
      end

      # CUSTOMER will be pulled first from the MC_EID if present on the order.source
      # IF that is not found, customer will be found by our Customer ID
      # IF that is not found, customer is created with the order email and our Customer ID
      def ensure_customer
        # use the one from mail chimp or fall back to the order's email
        # happens when this is a new user
        if @order.source
          customer_id = customer_id_from_eid(@order.source.email_id)
        end
        customer_id || upsert_customer
      end

      def mailchimp_customer_id_for_order(order)
        if order.user_id.present?
          "customer_#{order.user_id}"
        else
          "guest_#{email_from_order(order)}"
        end
      end

      def email_from_order(order)
        order.email.downcase
      end

      def customer_id_from_eid(mc_eid)
        email = Spree::Chimpy.list.email_for_id(mc_eid)
        if email
          begin
            response = store_api_call
              .customers
              .retrieve(params: { "fields" => "customers.id", "email_address" => email })

            data = response["customers"].first
            data["id"] if data
          rescue Gibbon::MailChimpError => e
            nil
          end
        end
      end

      private

      def upsert_customer
        customer_id = mailchimp_customer_id_for_order @order

        begin
          response = store_api_call
            .customers(customer_id)
            .retrieve(params: { "fields" => "id,email_address"})
        rescue Gibbon::MailChimpError => e
          # Customer Not Found, so create them
          response = store_api_call
            .customers
            .create(body: {
              id: customer_id,
              email_address: email_from_order(@order),
              opt_in_status: Spree::Chimpy::Config.subscribe_to_list || false
            })
        end
        customer_id
      end

    end
  end
end
