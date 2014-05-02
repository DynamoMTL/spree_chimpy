Spree::Core::Engine.add_routes do
  namespace :chimpy, path: "" do
    post 'subscribe' => 'subscribers#subscribe',   :as => :chimpy_subscribe
    post 'subscribe_to_list' => 'subscribers#subscribe_to_list'
    post 'refer_a_friend' => 'subscribers#refer_a_friend',   :as => :chimpy_refer_a_friend
  end
end
