Rails.application.routes.draw do
  get "signage/show"
  get "events/new"
  get "events/create"
  get "deadlines/index"
  root "deadlines#index"
  resources :events, only: [:new, :create]
  resources :deadlines, only: [:index]
  get "/signage", to: "signage#show"
end