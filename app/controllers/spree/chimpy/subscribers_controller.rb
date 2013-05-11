class Spree::Chimpy::SubscribersController < ApplicationController
  respond_to :html

  def create
    # Could do a check for a current user, and subscribe him instead
    # But should we then also update the e-mail of that current user? I don't think so
    @subscriber = Spree::Chimpy::Subscriber.new(params[:chimpy_subscriber])
    if @subscriber.save
      Spree::Chimpy::Subscription.new(@subscriber).subscribe
      flash[:notice] = I18n.t("spree.chimpy.subscriber.success")
    else
      flash[:error] = I18n.t("spree.chimpy.subscriber.failure")
    end
    respond_with @subscriber, location: request.referer
  end
end
