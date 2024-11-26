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
end
