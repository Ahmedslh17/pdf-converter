Rails.application.routes.draw do
  resources :conversions, only: [:new, :create, :show]
  root "conversions#new"
end