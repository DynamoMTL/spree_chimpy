module SpreeHominid
  module List
    extend self

    def api
      Hominid::API.new(Config.preferred_key)
    end

    def find(name)
      api.find_list_by_name(name)
    end
  end
end
