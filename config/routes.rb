Rails.application.routes.draw do
  resources :schedules
  resources :devices, param: :uid
  root to: 'static_pages#home'

  get 'mqtt', to: 'mqtt#index'

  post 'devices/statusUpdate', to: 'devices#statusUpdate'

  post 'test', to: 'static_pages#test'



  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
