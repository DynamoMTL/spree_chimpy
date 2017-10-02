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
        customer_id = customer_id_from_eid(@order.source.email_id) if @order.source
        customer_id || upsert_customer
      end

      def self.mailchimp_customer_id(user_id)
        "customer_#{user_id}"
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
        return unless @order.user_id

        customer_id = self.class.mailchimp_customer_id(@order.user_id)
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
              email_address: @order.email.downcase,
              opt_in_status: Spree::Chimpy::Config.subscribe_to_list || false
            })
        end
        customer_id
      end

    end
  end
end