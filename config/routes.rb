Rails.application.routes.draw do
  root 'application#root'

  namespace :admin do
    root 'admin#root'
    ###################################### Admin Login #############################
    match 'login', to: 'login#login', via: [:get, :post], as: :login
    match 'logout', to: 'login#logout', via: [:get, :post], as: :logout
    
    ###################################### APIs ##################################
    get "api_test", to: 'api_clients#test'

    ###################################### USSD Test #############################
    get "ussd_tests/flares"
    get "ussd_tests/mobile_gateway"

    resources :users, :api_clients do
      collection do
        match 'pages', via: [:get, :post]
        match 'export', via: [:get, :post]
        match 'upload_new', via: :get
        match 'upload_create', via: [:get, :post]
        match 'report', via: [:get, :post]
      end

      member do
        match 'reactivate', via: [:get, :put]
        match 'deactivate', via: [:get, :put]
      end
    end

    resources :users do
      member do
        match 'reset_password', via: [:get, :post, :put]
        match 'change_password', via: [:get, :post, :put]
      end
    end

    ##Default Admin::Base Controller routes

    #Collection
    ['pages', 'export', 'upload_new', 'upload_create', 'report'].each do |action|
      match "*resource_name/#{action}", to: "base##{action}", via: [:get, :post]
    end

    #Member
    ['reactivate', 'deactivate'].each do |action|
      match "*resource_name/*id/#{action}", to: "base##{action}", via: [:get, :put]
    end

    get "*resource_name/new", to: 'base#new'
    post "*resource_name", to: 'base#create'

    get "*resource_name/*id/edit", to: 'base#edit'
    put "*resource_name/*id", to: 'base#update'
    
    get "*resource_name/*id", to: 'base#show'
    get "*resource_name", to: 'base#index'
  end

  namespace :api do

    ##Default Admin::Base Controller routes

    #Resources

    #Collection
    ['pages', 'export', 'upload_new', 'upload_create', 'report'].each do |action|
      match "*resource_name/#{action}", to: "base##{action}", via: [:get, :post]
    end

    #Member
    ['reactivate', 'deactivate'].each do |action|
      match "*resource_name/*id/#{action}", to: "base##{action}", via: [:get, :put]
    end
    get "*resource_name/new", to: 'base#new'
    post "*resource_name", to: 'base#create'

    get "*resource_name/*id/edit", to: 'base#edit'
    put "*resource_name/*id", to: 'base#update'
    
    get "*resource_name/*id", to: 'base#show'
    get "*resource_name", to: 'base#index'
  end

  ###################################### USSD #############################
  get "ussd/flares", to: 'ussd#flares'
  get "ussd/mobile_gateway", to: 'ussd#mobile_gateway'

  get '*unmatched_route', to: 'application#not_found'  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
