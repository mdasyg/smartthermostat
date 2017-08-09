Rails.application.routes.draw do
  root to: 'static_pages#home'

  get '/devices/search', to: 'devices#search' # must be placed before 'devices' resources

  resources :schedules
  resources :devices, param: :uid

  get '/devices/:uid/get_device_attributes_list', to: 'devices#get_device_attributes_list'
  post '/devices/:uid/update_device_attribute_value', to: 'devices#update_device_attribute_value'

  get 'schedules/:id/get_overlapping_schedules', to: 'schedules#get_overlapping_schedules'
  post 'schedules/update_overlapping_schedules_priorities', to: 'schedules#update_overlapping_schedules_priorities'

  get '/admin', to: 'admin#index'
  get '/admin/manage_value_types', to: redirect('/admin')
  post '/admin/manage_value_types', to: 'admin#manage_value_types'

  devise_for :users # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # api routes
  namespace(:api) do
    namespace(:v1) do
      post '/devices/:uid/stats_update', to: 'devices#stats_update'
      post '/devices/:uid/attributes_status_update', to: 'devices#attributes_status_update'
      # post '/devices/attributes_list', to: 'devices#attributes_list'
    end
  end
end
