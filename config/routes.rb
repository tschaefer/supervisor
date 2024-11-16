Rails.application.routes.draw do
  Healthcheck.routes(self)

  resources :stacks, param: :uuid
  post 'stacks/:uuid/webhook', to: 'stacks#webhook', as: :stack_webhook
  get 'stacks/:uuid/stats', to: 'stacks#stats', as: :stack_stats
  post 'stacks/:uuid/control', to: 'stacks#control', as: :stack_control
  get 'stacks/:uuid/last_logs_entry', to: 'stacks#last_logs_entry', as: :stack_last_logs_entry
  get 'stacks/:uuid/logs', to: 'stacks#logs', as: :stack_logs
end
