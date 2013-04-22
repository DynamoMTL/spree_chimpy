module SpreeHominid
  class Subscription
    API_VERSION = '1.3'

    def initialize(user)
      return unless enabled?
      @user = user
      @api  = Hominid::API.new(SpreeHominid::Config.preferred_key, api_version: API_VERSION)
    end

    def subscribe
      return unless enabled?
      @api.list_subscribe(list['id'], @user.email)
    end

    def unsubscribe
      return unless enabled?
      @api.list_unsubscribe(list['id'], @user.email)
    end

    def sync
    end

    def list
      @list ||= @api.find_list_by_name(Config.preferred_list_name)
    end

  private
    def enabled?
      Config.preferred_key.present?
    end
  end
end
