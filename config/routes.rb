Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"


  # resources :profiles, only: [:new, :create, :show, :edit, :update]
  # resources :readings, only: [:index, :show, :new, :create, :destroy]
resources :profiles, only: [:new, :create, :show]
resources :readings, only: [:index, :show, :new, :create, :destroy]
resource :natal_charts, only: [:show, :create]
end
