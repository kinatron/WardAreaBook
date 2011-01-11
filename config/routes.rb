ActionController::Routing::Routes.draw do |map|
  map.connect '/action_items/wardActionItems/', :controller => 'action_items', 
                                               :action => 'wardActionItems'
  map.resources :action_items

  map.resources :comments

  map.resources :callings

  map.connect '/callings/updateAccessLevels/', :controller => 'callings', 
                                               :action => 'updateAccessLevels'
  map.resources :name_mappings

  map.connect '/teaching_routes/updateNames/', :controller => 'teaching_routes', 
                                               :action => 'updateNames'
  map.connect '/teaching_routes/updateError/', :controller => 'teaching_routes', 
                                               :action => 'updateError'
  map.connect '/teaching_routes/updateRoutes/', :controller => 'teaching_routes', 
                                               :action => 'updateRoutes'
  map.connect '/teaching_routes/teacherList/', :controller => 'teaching_routes', 
                                               :action => 'teacherList'
  map.resources :teaching_routes

  map.resources :teaching_records

  map.resources :users

  map.connect '/WardListUpdates', :controller => 'people', :action => 'WardListUpdates'

  map.resources :people

  map.resources :events

  map.resources :roster


#  map.connect '/login', :controller => 'families', :action => 'index'
  map.connect '/families/members/', :controller => 'families', :action => 'members'
  map.connect '/families/teachingPool/', :controller => 'families', :action => 'teachingPool'
  map.connect '/families/investigators/', :controller => 'families', :action => 'investigators'
  map.connect '/families/mergeRecords/', :controller => 'families', :action => 'mergeRecords'
  map.connect '/families/new_comment/', :controller => 'families', :action => 'new_comment'

  map.resources :families
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "families"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
