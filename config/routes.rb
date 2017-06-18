Rails.application.routes.draw do
  root to: 'static_pages#home'

  resources :schedules
  resources :devices, param: :uid

  get '/devices/:uid/get_device_attributes_list', to: 'devices#get_device_attributes_list'

  get '/admin', to: 'admin#index'

  get '/admin/manage_value_types', to: redirect('/admin')
  post '/admin/manage_value_types', to: 'admin#manage_value_types'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # api
  namespace(:api) do
    namespace(:v1) do
      get '/devices/:uid/attributes', to: 'devices#attributes'
    end
  end

  # get 'mqtt', to: 'mqtt#index'
  # post 'devices/statusUpdate', to: 'devices#statusUpdate'
  # post 'test', to: 'static_pages#test'
end
