module SpreeHominid
  module ApplicationControllerFilters
    extend ActiveSupport::Concern

    included { before_filter :find_campaign }

  private
    def find_campaign
      session[:campaign_id] = params[:mc_id] if params[:mc_id]
    end
  end
end
