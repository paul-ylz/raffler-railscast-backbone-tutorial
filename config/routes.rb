Rails.application.routes.draw do

  scope :api do
    resources :entries
  end

  root 'main#index'
  get '*path', to: 'main#index'
end
