class Spree::Chimpy::SubscribersController < ApplicationController
  respond_to :html

  def create
    @subscriber = Spree::Chimpy::Subscriber.new(params[:subscriber])

    if @subscriber.save
      Spree::Chimpy::Subscription.new(@subscriber).subscribe
      flash[:notice] = I18n.t("spree.chimpy.subscriber.success")
    else
      flash[:error] = I18n.t("spree.chimpy.subscriber.failure")
    end

    respond_with @subscriber, location: request.referer
  end
end
