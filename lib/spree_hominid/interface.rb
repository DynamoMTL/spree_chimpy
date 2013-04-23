module SpreeHominid
  class Interface
    API_VERSION = '1.3'

    def initialize(key)
      @api = Hominid::API.new(key, api_version: API_VERSION)
    end

    def subscribe(list_name, email)
      list_id = find_list_id(list_name)
      @api.list_subscribe(list_id, email)
    end

    def unsubscribe(list_name, email)
      list_id = find_list_id(list_name)
      @api.list_unsubscribe(list_id, email)
    end

    def find_list_id(name)
      @api.find_list_id_by_name(name)
    end
  end
end
