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
    mailchimp_action = Spree::Chimpy::Action.new(email: params[:referrerEmail], request_params: params.to_json, source: params[:source], action: :referrer)
    if mailchimp_action.save
      double_opt_in = false
      
      referee_batch = params[:refereeEmails].map do |email| 
        if email.present? and email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          { email: {email: email}, 
            merge_vars: { "REFERRER" => params[:referrerEmail] } } 
        end
      end.compact

      list = Spree::Chimpy::Interface::List.new(params[:referee_list_name], 'customers', double_opt_in)
      res = list.batch_subscribe(referee_batch)

      list = Spree::Chimpy::Interface::List.new(params[:referrer_list_name], 'customers', double_opt_in)
      res = list.batch_subscribe([{email: {email: params[:referrerEmail]} }])

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
