Rails.application.routes.draw do
  root to: 'static_pages#home'

  resources :schedules
  resources :devices, param: :uid

  get '/devices/:uid/get_properties_list', to: 'devices#get_properties_list'

  get '/admin', to: 'admin#index'

  get '/admin/manage_value_types', to: redirect('/admin')
  post '/admin/manage_value_types', to: 'admin#manage_value_types'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # get 'mqtt', to: 'mqtt#index'
  # post 'devices/statusUpdate', to: 'devices#statusUpdate'
  # post 'test', to: 'static_pages#test'
end
