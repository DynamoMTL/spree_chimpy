Spree::Core::Engine.routes.draw do
  namespace :chimpy, path: "" do
    resource :subscribers, only: [:create]
  end
end
