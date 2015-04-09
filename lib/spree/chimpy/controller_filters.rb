module Spree::Chimpy
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_mailchimp_params
      before_filter :find_mail_chimp_params, if: :mailchimp_params?
      include ::Spree::Core::ControllerHelpers::Order
    end

    private

    attr_reader :mc_eid, :mc_cid

    def set_mailchimp_params
      @mc_eid = params[:mc_eid] || session[:mc_eid]
      @mc_cid = params[:mc_cid] || session[:mc_cid]
    end

    def mailchimp_params?
      (!mc_eid.nil? || !mc_cid.nil?) &&
        (!session[:order_id].nil? || !params[:record_mc_details].nil?)
    end

    def find_mail_chimp_params
      attributes = { campaign_id: mc_cid, email_id: mc_eid }
      if current_order(create_order_if_necessary: true).source
        current_order.source.update_attributes(attributes)
      else
        current_order.create_source(attributes)
      end
    end
  end
end
