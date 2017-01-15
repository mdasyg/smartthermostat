Rails.application.routes.draw do
  resources :devices
  root to: 'static_pages#home'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
