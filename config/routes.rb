Rails.application.routes.draw do
  resources :gateway_messages
  resources :homes
  resources :motion_sensors
  resources :water_level_sensors
  resources :sensors
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
