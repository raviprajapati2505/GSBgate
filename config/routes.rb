Rails.application.routes.draw do
  resources :certification_paths
  resources :projects do
    resources :project_authorizations, only: [ :index, :new, :create, :edit, :update, :destroy ], path: 'authorizations'
    resources :certification_paths, except: [ :edit, :update, :destroy ], path: 'certificates' do
      resources :scheme_mixes, only: [ :edit, :show ], path: 'schemes' do
        resources :scheme_mix_criteria, only: [:edit, :update], path: 'criteria', as: 'scheme_mix_criterion'
      end
    end
    resources :requirement_data, only: [:update], path: 'requirement', as: 'requirement_data'
  end

  resources :users
  devise_for :user

  controller :project_authorizations do
    post 'projects/:project_id/permissions' => :update_permissions, as: 'update_permissions'
    delete 'projects/:project_id/users/:user_id/permissions' => :destroy_permissions, as: 'destroy_permissions'
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'projects#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
