Rails.application.routes.draw do
  # https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :sessions do
    member do
      get 'prompt'
      post 'prompt'
      post 'clear'
    end
  end
end
