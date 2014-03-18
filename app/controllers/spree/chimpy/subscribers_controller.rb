class Spree::Chimpy::SubscribersController < Spree::BaseController
  def subscribe
    user = find_or_create_user
    if user.subscribe(params[:source])
      response = { response: :success, message: I18n.t("spree.chimpy.success") }
    else
      response = { response: :failure, message: I18n.t("spree.chimpy.failure") }
    end

    render json: response, layout: false
  end
  
  def unsubscribe
    user = find_or_create_user

    if user.unsubscribe(params[:source])
      response = { response: :success, message: I18n.t("spree.chimpy.success") }
    else
      response = { response: :failure, message: I18n.t("spree.chimpy.failure") }
    end

    render json: response, layout: false
  end

  def refer_a_friend
    mailchimp_action = Spree::Chimpy::Action.new(email: params[:referrer_email], request_params: params.to_json, source: params[:source], action: :referrer)
    if mailchimp_action.save
      emails = params[:refereeEmails]
      emails.each do |email|
        if email.present?
          user = Spree.user_class.find_or_create_unenrolled(email, tracking_cookie)
          user.subscribe(params[:referrer_email])
        end
      end

      response = { response: :success, message: I18n.t("spree.chimpy.success") }
    else
      response = { response: :failure, message: I18n.t("spree.chimpy.failure") }
    end
    
    render json: response, layout: false
  end

  private

  def find_or_create_user
    Spree.user_class.find_or_create_unenrolled(params[:signupEmail], tracking_cookie)
  end

end
