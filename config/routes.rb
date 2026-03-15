Rails.application.routes.draw do
  get "entries/update_status"
  get "signage/show"
  get "events/new"
  get "events/create"
  get "deadlines/index"
  post "/analyze_url", to: "events#analyze_url"
  root "deadlines#index"
  resources :events, only: [:new, :create, :edit, :update]
  resources :deadlines, only: [:index]
  resources :entries, only: [] do
    member do
      patch :update_status
    end
  end
  get "/signage", to: "signage#show"
end
