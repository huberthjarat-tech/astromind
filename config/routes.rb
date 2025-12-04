Rails.application.routes.draw do
  get 'natal_charts/show'
  get 'natal_charts/create'
  devise_for :users
  root to: "pages#home"


  # resources :profiles, only: [:new, :create, :show, :edit, :update]
  # resources :readings, only: [:index, :show, :new, :create, :destroy]
resource :profile, only: [:new, :create, :show]
resources :readings, only: [:index, :show, :new, :create, :destroy]
resource :natal_chart, only: [:show, :create]
end
