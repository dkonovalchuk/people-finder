Rails.application.routes.draw do

  root 'static_pages#index'

  namespace :api do
    get :find, to: "find#show", defaults: { format: :json }
  end
end
