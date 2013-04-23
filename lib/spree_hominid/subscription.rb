module SpreeHominid
  class Subscription
    API_VERSION = '1.3'

    def initialize(user)
      @user       = user
      @changes    = user.changes.dup
      @interface  = Config.interface
    end

    def subscribe
      @interface.subscribe(Config.preferred_list_name, @user.email, users_merge_vars) if @interface && @user.subscribed
    end

    def unsubscribe
      @interface.unsubscribe(Config.preferred_list_name, @user.email) if @interface
    end

    def needs_update?
      @user.subscribed && attributes_changed?
    end

    def sync
      if @changes[:subscribed] && !@user.subscribed
        unsubscribe
      else
        subscribe
      end
    end

  private
    def attributes_changed?
      merge_vars.values.any? do |attr|
        @user.send("#{attr}_changed?")
      end
    end

    def users_merge_vars
      array = merge_vars.except('EMAIL').map do |tag, method|
        [tag, @user.send(method)]
      end

      Hash[array]
    end

    def merge_vars
      Config.preferred_merge_vars
    end
  end
end
