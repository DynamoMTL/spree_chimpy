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

  def subscribe_to_list
    email = params[:signupEmail]
    if email.present? and email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      ::Delayed::Job.enqueue(Spree::Chimpy::ListSubscriber.new(params[:list_name],
      double_opt_in,
      params[:signupEmail],
      params[:source]))
      response = { response: :success, message: I18n.t("spree.chimpy.success") }
    else
      response = { response: :failure, message: I18n.t("spree.chimpy.failure") }
    end
    render json: response, layout: false
  end


  def refer_a_friend
    mailchimp_action = Spree::Chimpy::Action.new(email: params[:referrerEmail], request_params: params.to_json, source: params[:source], action: :referrer)
    if mailchimp_action.save && valid_referees(params[:refereeEmails])
      referee_batch = params[:refereeEmails].map do |email|
        if email.present? and email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          { email: {email: email},
            merge_vars: { "REFERRER" => params[:referrerEmail] } }
        end
      end.compact

      ::Delayed::Job.enqueue(Spree::Chimpy::BatchSubscriber.new(params[:referee_list_name],
                                                                double_opt_in,
                                                                referee_batch))

      ::Delayed::Job.enqueue(Spree::Chimpy::ListSubscriber.new(params[:referrer_list_name],
                                                               double_opt_in,
                                                               params[:referrerEmail],
                                                               params[:source]))

      response = { response: :success, message: I18n.t("spree.chimpy.success") }
    else
      Rails.logger.warning "Failed to add #{params[:refereeEmails]} to list because of #{mailchimp_action.errors.messages}"
      response = { response: :failure, message: I18n.t("spree.chimpy.failure") }
    end

    render json: response, layout: false
  end

  private

  def valid_referees(emails)
    safe_emails = emails.compact.reject { |e| e.blank? }
    safe_emails.all?{ |email| email.present? && email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  end

  def find_or_create_user
    Spree.user_class.find_or_create_unenrolled(params[:signupEmail], tracking_cookie)
  end

  def double_opt_in
    false
  end

end
