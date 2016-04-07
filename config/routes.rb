Rails.application.routes.draw do

  namespace :api do
    patch  'insert'     => 'money#insert'
    patch 'exchange'   => 'money#exchange'
  end
end