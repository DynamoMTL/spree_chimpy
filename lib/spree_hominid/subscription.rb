module SpreeHominid
  class Subscription
    API_VERSION = '1.3'

    def initialize(user)
      @user       = user
      @changes    = user.changes.dup
      @interface  = Config.interface
    end

    def subscribe
      @interface.subscribe(Config.preferred_list_name, @user.email) if @interface && @user.subscribed
    end

    def unsubscribe
      @interface.unsubscribe(Config.preferred_list_name, @user.email) if @interface
    end

    def needs_update?
      Config.preferred_merge_vars.values.any? do |attr|
        method = "#{attr}_changed?".to_sym
        @user.send(method) if @user.methods.include?(method)
      end
    end

    def sync
      if @changes[:subscribed] && !@user.subscribed
        unsubscribe
      else
        subscribe
      end
    end
  end
end
