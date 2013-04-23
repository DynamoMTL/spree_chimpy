module SpreeHominid
  class Subscription
    API_VERSION = '1.3'

    def initialize(user)
      @user       = user
      @interface  = Config.interface
    end

    def subscribe
      @interface.subscribe(Config.preferred_list_name, @user.email) if @interface
    end

    def unsubscribe
      @interface.unsubscribe(Config.preferred_list_name, @user.email) if @interface
    end

    def sync
    end
  end
end
