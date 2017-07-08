Rails.application.routes.draw do
  root to: 'static_pages#home'

  resources :schedules
  resources :devices, param: :uid

  post '/devices/:uid/update_device_attribute_value', to: 'devices#update_device_attribute_value'

  get '/admin', to: 'admin#index'

  get '/admin/manage_value_types', to: redirect('/admin')
  post '/admin/manage_value_types', to: 'admin#manage_value_types'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # api
  namespace(:api) do
    namespace(:v1) do
      post '/devices/attributes_list', to: 'devices#attributes_list'

      post '/devices/status', to: 'devices#status'
      post '/devices/attributes_status', to: 'devices#attributes_status'
    end
  end

  # get 'mqtt', to: 'mqtt#index'
  # post 'test', to: 'static_pages#test'
end
