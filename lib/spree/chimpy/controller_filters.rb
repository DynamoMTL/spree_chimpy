module Spree::Chimpy
  module ControllerFilters
    extend ActiveSupport::Concern

    included { before_filter :find_mail_chimp_params }

  private
    def find_mail_chimp_params
      if params[:mc_eid] || params[:mc_cid]
        attributes = {campaign_id: params[:mc_cid],
                      email_id:    params[:mc_eid]}

        if current_order(true).source
          current_order.source.update_attributes(attributes)
        else
          current_order.create_source(attributes)
        end
      end
    end
  end
end
