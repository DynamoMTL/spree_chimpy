Spree::Core::Engine.add_routes do
  namespace :chimpy, path: "" do
    resource :subscribers, only: [:create]
  end
end
