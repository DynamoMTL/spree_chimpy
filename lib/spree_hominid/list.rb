module SpreeHominid
  module List
    extend self

    def api
      @api ||= Hominid::API.new(Config.preferred_key)
    end

    def subscribe(user)
      api.list_subscribe(list['id'], user.email)
    end

    def unsubscribe(user)
    end

    def sync(user)
    end

    def list
      @list ||= api.find_by_name(Config.preferred_list_name)
    end
  end
end

