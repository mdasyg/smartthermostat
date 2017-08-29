Rails.application.routes.draw do
  root to: 'static_pages#home'

  get '/devices/search', to: 'devices#search' # must be placed before 'devices' resources

  resources :schedules
  resources :devices, param: :uid
  resources :quick_buttons

  get '/devices/:uid/get_device_attributes_list', to: 'devices#get_device_attributes_list'
  post '/devices/:uid/update_device_attribute_value', to: 'devices#update_device_attribute_value'

  get 'schedules/:id/get_overlapping_schedules', to: 'schedules#get_overlapping_schedules'
  post 'schedules/update_overlapping_schedules_priorities', to: 'schedules#update_overlapping_schedules_priorities'

  devise_for :users # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # api routes
  namespace(:api) do
    namespace(:v1) do
      post '/devices/:uid/stats_update', to: 'devices#stats_update'
      post '/devices/:uid/attributes_status_update', to: 'devices#attributes_status_update'
      get '/devices/:uid/get_info', to: 'devices#get_info'
    end
  end
end
