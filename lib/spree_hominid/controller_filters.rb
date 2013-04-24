module SpreeHominid
  module ControllerFilters
    extend ActiveSupport::Concern

    included { before_filter :find_mail_chimp_email_id }

  private
    def find_mail_chimp_email_id
      session[:mc_eid] = params[:mc_eid] if params[:mc_eid]
    end
  end
end
