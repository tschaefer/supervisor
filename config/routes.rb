Rails.application.routes.draw do
  Healthcheck.routes(self)

  resources :stacks, param: :uuid
  post 'stacks/:uuid/webhook', to: 'stacks#webhook', as: :stack_webhook
  get 'stacks/:uuid/stats', to: 'stacks#stats', as: :stack_stats
end
