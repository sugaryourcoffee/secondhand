Secondhand::Application.routes.draw do

  scope '(:locale)' do
    root to: 'static_pages#home'

    match '/signup',  to: 'users#new'
    match '/signin',  to: 'sessions#new'
    match '/signout', to: 'sessions#destroy', via: :delete

    match '/about',   to: 'static_pages#about'
    match '/help',    to: 'static_pages#help'
    match '/contact', to: 'static_pages#contact'
    match '/message', to: 'static_pages#message'

    get   '/who_registered' => 'users#who_registered', 
                               defaults: { format: 'atom' }
    get   '/which_list'     => 'lists#which_list_is_registered_or_closed',
                               defaults: { format: 'atom' }

    resources :acceptances, only: [:index, :edit] do
      member do
        get    :edit_list
        put    :update_list
        get    :edit_item
        put    :update_item
        delete :delete_item
        post   :accept
      end
    end

    resources :line_items, only: [:create, :destroy]

    resources :carts do
      collection do
        get :item_collection
        get :line_item_collection
      end
      member do
        delete :delete_item
      end
    end

    resources :sellings do
      member do
        get :check_out
      end
    end

    resources :reversals, only: [:index, :create, :show, :destroy] do
      member do
        get :check_out
      end
    end

    resources :lists do
      member do
        get :items
      end
      resources :items
    end

    resources :users do
      member do
        post :register_list
        post :deregister_list
        get :print_address_labels, defaults: { format: 'pdf' }
      end
      resources :lists do
        member do
          get :print_list, defaults: { format: 'pdf' }
          get :print_labels, defaults: { format: 'pdf' }
          get :send_list
        end
        resources :items, only: [:index, :new, :create, :show, :edit, :destroy,
                                 :update]
      end
    end

    resources :news do
      member do
        get :send_newsletter
      end
    end

    resources :sessions, only: [:new, :create, :destroy]

    resources :password_resets

    resources :events do
      member do
        post :activate
        get :print_pickup_tickets, defaults: { format: 'pdf' }
      end
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
