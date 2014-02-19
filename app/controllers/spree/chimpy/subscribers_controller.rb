class Spree::Chimpy::SubscribersController < ApplicationController
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

  # check if it works before using it
  def refer_a_friend
    mailchimp_action = Spree::Chimpy::Action.new(refer_a_friend_params.merge(request_params: params.to_json))
    if mailchimp_action.save
      emails = refer_a_friend_params[:refereeEmails] # check this
      emails.each do |email|
        if email.present?
          mailchimp_action = Spree::Chimpy::Action.create(action = :referrered, source: params[:referrer_email])
          user = Spree.user_class.find_or_create_unenrolled(email)
          user.subscribe(refer_a_friend_params[:signupEmail])
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

  def refer_a_friend_params
    params.require(:refer_a_friend).permit(:signupEmail, :refereeEmails, :source)
  end
end
