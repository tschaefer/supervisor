Rails.application.routes.draw do
  Healthcheck.routes(self)

  resources :stacks, param: :uuid do
    member do
      post  'webhook'
      get   'stats'
      post  'control'
      get   'log'
    end
  end

  get '/dashboard', to: 'dashboard#index'
  get '/storage/stack/:uuid/stack.log', to: 'dashboard#log'

  root to: 'dashboard#index'
end
