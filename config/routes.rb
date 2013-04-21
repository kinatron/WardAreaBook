WardAreaBook::Application.routes.draw do
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

  match '/faq' => 'static_pages#faq'

  match '/action_items/wardActionItems/' => 'action_items#wardActionItems'
  resources :action_items, :only => [:create, :update, :destroy]
  resources :comments, :only => [:update, :destroy]

  get '/teaching_routes' => 'teaching_routes#index'
  get '/teaching_routes/update_routes/' => 'teaching_routes#update_routes'
  post '/teaching_routes/update_routes/' => 'teaching_routes#upload_file'
  match '/teaching_routes/update_names/' => 'teaching_routes#update_names'
  match '/teaching_routes/update_error/' => 'teaching_routes#update_error'
  post '/teaching_routes/update_with_path/' => 'teaching_routes#update_with_path'
  match '/teaching_routes/teacherList/:id' => 'teaching_routes#teacherList'

  get '/visiting_teaching' => 'visiting_teaching#index'
  get '/visiting_teaching/update_routes/' => 'visiting_teaching#update_routes'
  post '/visiting_teaching/update_routes/' => 'visiting_teaching#upload_file'
  post '/visiting_teaching/update_with_path/' => 'visiting_teaching#update_with_path'
  match '/visiting_teaching/update_names/' => 'visiting_teaching#update_names'
  match '/visiting_teaching/update_error/' => 'visiting_teaching#update_error'
  match '/visiting_teaching/teacher_list/' => 'visiting_teaching#teacher_list'

  match '/todo' => 'users#todo'
  resources :users, :only => [:index, :new, :create, :update, :destroy]

  match '/WardListUpdates' => 'people#WardListUpdates'
  resources :people

  # Haven't gotten to yet
  resources :events
  resources :password_resets
  resources :roster
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  resources :user_sessions
  match '/families/members/' => 'families#members'
  match '/families/teachingPool/' => 'families#teachingPool'
  match '/families/investigators/' => 'families#investigators'
  match '/families/mergeRecords/' => 'families#mergeRecords'
  post '/families/:id/new_comment' => 'families#new_comment'
  match '/families/edit_status/:id' => 'families#edit_status'
  match '/activate/:id' => 'password_resets#activate', :as => :activation
  resources :families
  match '/' => 'families#index'
  match '/:controller(/:action(/:id))'

  # Unsure what is used but look safe
  resources :callings
  match '/callings/updateAccessLevels/' => 'callings#updateAccessLevels'

  # Unsure about
  resources :auth_users
  resources :teaching_records
end
