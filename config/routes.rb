Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :chimpy, path: "" do
    resource :subscribers, only: [:create]
  end
end
