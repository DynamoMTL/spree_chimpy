module Spree::Chimpy
  module ControllerFilters
    extend ActiveSupport::Concern

    included do |variable|
      before_filter :find_mail_chimp_params
      
      include ::Spree::Core::ControllerHelpers::Order

    private
      def find_mail_chimp_params
        mc_eid = params[:mc_eid] || session[:mc_eid]
        mc_cid = params[:mc_cid] || session[:mc_cid]
        if (mc_eid || mc_cid) && (session[:order_id] || params[:record_mc_details])
          attributes = {campaign_id: mc_cid,
                        email_id:    mc_eid}
          if current_order(create_order_if_necessary: true).source
            current_order.source.update_attributes(attributes)
          else
            current_order.create_source(attributes)
          end
        end
      end
    end
  end
end
