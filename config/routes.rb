Rails.application.routes.draw do

  scope '(:locale)' do
    root                'static_pages#home' # root to: 'static_pages#home'

    get    'signup'  => 'users#new'         # match '/signup',  
                                            # to: 'users#new'
    get    'signin'  => 'sessions#new'      # match '/signin',  
                                            # to: 'sessions#new'
    delete 'signout' => 'sessions#destroy'  # match '/signout', 
                                            # to: 'sessions#destroy', 
                                            # via: :delete

    get    'about'   => 'static_pages#about' # match '/about',   
                                             # to: 'static_pages#about'
    get    'help'    => 'static_pages#help'  # match '/help',    
                                             # to: 'static_pages#help'
    get    'contact' => 'static_pages#contact' # match '/contact', 
                                               # to: 'static_pages#contact'
    post   'message' => 'static_pages#message' # match '/message', 
                                               # to: 'static_pages#message'

    get   '/who_registered' => 'users#who_registered', 
                               defaults: { format: 'atom' }
    get   '/which_list'     => 'lists#which_list_is_registered_or_closed',
                               defaults: { format: 'atom' }

    get   'display_terms_of_use' => 'submit_terms_of_use#display'
    get   'accept_terms_of_use'  => 'submit_terms_of_use#accept'

    get   'statistics/overview' => 'statistics#describe'
    get   'statistics/sales'     => 'statistics#graphic'

    resources :terms_of_use do
      member do
        get :copy
      end
      resources :pages do
        member do
          get :up
          get :down
        end
      end
    end

    resources :conditions do
      member do
        get :copy
        get :activate
      end
    end

    resources :query, only: [:index]

    resources :counter, only: [:index]

    resources :acceptances, only: [:index, :edit] do
      member do
        get    :edit_list, format: 'js'
        patch  :update_list
        get    :edit_item
        patch  :update_item
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
        get :print
      end
    end

    resources :reversals, only: [:index, :create, :show, :destroy] do
      member do
        get :check_out
        get :print
      end
    end

    resources :lists do
      member do
        get :items
        get :sold_items
      end
      resources :items
      get  'select_file'  => 'importer#file'
      get  'select_lists' => 'importer#lists'
      post 'select_items' => 'importer#select'
      post 'import_items' => 'importer#items'
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
        get :print_lists,          defaults: { format: 'pdf' }
        get :create_lists_as_pdf
      end
      collection { get :download_lists_as_pdf }
    end
  end

end
