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
            #data["id"] if data
            if data
              update_cutomer_orders(data["id"])
              data["id"]
            end
          rescue Gibbon::MailChimpError => e
            nil
          end
        end
      end

      private

      def upsert_customer
        customer_id = @order.user_id || "#{@order.email.downcase}"

        customer_id = self.class.mailchimp_customer_id(customer_id)
        begin
          response = store_api_call
            .customers(customer_id)
            .retrieve(params: { "fields" => "id,email_address"})
          update_cutomer_orders(response) if response.present? && response['id'].present?
        rescue Gibbon::MailChimpError => e
          # Customer Not Found, so create them
          response = store_api_call
            .customers
            .create(body: data.merge(id: customer_id))
        end
        customer_id
      end

      def update_cutomer_orders(customer)
        store_api_call
          .customers(customer['id'])
          .update(body: data.merge(id: customer['id']))
      end

      def data
        {
          email_address: @order.email.downcase,
          opt_in_status: true,
          orders_count: customer_orders.count,
          total_spent: total_spent
        }
      end

      def total_spent
        customer_orders.pluck(:total).sum.round(2)
      end

      def customer_orders
        Spree::Order.complete.where('email=?', @order.email)
      end

    end
  end
end