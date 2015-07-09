Rails.application.routes.draw do
  resources :certification_paths
  resources :projects, except: [ :destroy ] do
    resources :project_authorizations, only: [ :new, :edit, :show, :update, :destroy ], path: 'authorizations', as: 'authorization'
    resources :project_authorizations, only: [ :create ], path: 'authorizations', as: 'authorizations'
    resources :certification_paths, except: [ :destroy ], path: 'certificates' do
      resources :scheme_mixes, only: [ :edit, :show ], path: 'schemes' do
        resources :scheme_mix_criteria, only: [ :edit, :show, :update ], path: 'criteria', as: 'scheme_mix_criterion' do
          resources :scheme_mix_criterion_logs, only: [ :index ], path: 'status_logs', as: 'status_logs'
          resources :scheme_mix_criteria_documents, only: [ :create, :edit, :show, :update, :destroy ], path: 'documentation', as: 'scheme_mix_criteria_documents' do
            resources :scheme_mix_criteria_document_comments, only: [ :create ], path: 'comments', as: 'scheme_mix_criteria_document_comments'
          end
        end
      end
    end
    resources :requirement_data, only: [ :update ], path: 'requirement', as: 'requirement_data'
  end
  resources :notifications, only: [ :index ]
  resources :documents, only: [ :create, :show ], path: 'document'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:id/assign' => 'scheme_mix_criteria#assign_certifier', as: 'assign_certifier_to_criteria'

  resources :users
  get 'projects/:project_id/users/new' => 'users#new_member', as: 'new_project_user'
  devise_for :user

  # Error pages
  match '/403', to: 'errors#forbidden', via: :all, as: 'forbidden_error'
  match '/404', to: 'errors#not_found', via: :all, as: 'not_found_error'
  match '/422', to: 'errors#unprocessable_entity', via: :all, as: 'unprocessable_entity_error'
  match '/500', to: 'errors#internal_server_error', via: :all, as: 'internal_server_error_error'
  
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
