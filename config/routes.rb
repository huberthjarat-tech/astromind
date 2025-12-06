Rails.application.routes.draw do
  get 'natal_charts/show'
  get 'natal_charts/create'
  get 'services', to: 'pages#services', as: :services
  #TAROT
  get  "readings/tarot/new",  to: "readings#new_tarot",    as: :new_tarot_reading
  post "readings/tarot",      to: "readings#create_tarot", as: :tarot_readings
  #HOROSCOPE
  get  "readings/horoscope/new",  to: "readings#new_horoscope",    as: :new_horoscope_reading
  post "readings/horoscope",      to: "readings#create_horoscope", as: :horoscope_readings

  devise_for :users
  root to: "pages#home"


  # resources :profiles, only: [:new, :create, :show, :edit, :update]

resource :profile, only: [:new, :create, :show]
resources :readings, only: [:index, :show, :new, :create, :destroy]
resource :natal_chart, only: [:show, :create]
end
