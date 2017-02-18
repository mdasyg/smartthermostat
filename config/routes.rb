Rails.application.routes.draw do
  resources :devices, param: :uid
  root to: 'static_pages#home'

  get 'mqtt', to: 'mqtt#index'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
