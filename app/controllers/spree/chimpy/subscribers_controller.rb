class Spree::Chimpy::SubscribersController < ApplicationController
  respond_to :html, :json

  def create
    @subscriber = Spree::Chimpy::Subscriber.where(email: subscriber_params[:email]).first_or_initialize
    @subscriber.email = subscriber_params[:email]
    @subscriber.subscribed = subscriber_params[:subscribed]
    if @subscriber.save
      flash[:notice] = Spree.t(:success, scope: [:chimpy, :subscriber])
    else
      flash[:error] = Spree.t(:failure, scope: [:chimpy, :subscriber])
    end

    referer = request.referer || root_url # Referer is optional in request.
    respond_with @subscriber, location: referer
  end

  private

    def subscriber_params
      params.require(:chimpy_subscriber).permit(:email, :subscribed)
    end
end
