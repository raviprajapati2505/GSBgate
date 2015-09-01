Rails.application.routes.draw do
  resources :projects, except: [ :destroy ] do
    resources :project_authorizations, only: [ :edit, :show, :update, :destroy ], path: 'authorizations', as: 'authorization'
    resources :project_authorizations, only: [ :create ], path: 'authorizations', as: 'authorizations'
    resources :certification_paths, except: [ :index, :new, :edit, :destroy ], path: 'certificates' do
      resources :documents, only: [ :create, :show ], path: 'document'
      resources :scheme_mixes, only: [ :show ], path: 'schemes' do
        resources :scheme_mix_criteria, only: [ :show, :update ], path: 'criteria', as: 'scheme_mix_criterion' do
          resources :requirement_data, only: [ :update ], path: 'requirement', as: 'requirement_data'
          resources :scheme_mix_criteria_documents, only: [ :create, :show, :update ], path: 'documentation', as: 'scheme_mix_criteria_documents' do
          end
        end
      end
    end
  end
  get 'audit_logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_index', as: 'auditable_index_audit_logs'
  post 'audit_logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_create', as: 'auditable_create_audit_log'
  put 'projects/:project_id/certificates/:id/sign' => 'certification_paths#sign_certificate', as: 'sign_certification_path'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:id/assign' => 'scheme_mix_criteria#assign_certifier', as: 'assign_certifier_to_criteria'
  get 'projects/:project_id/certificates/:id/archive' => 'certification_paths#download_archive', as: 'archive_project_certification_path'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:id/allocate-project-team-responsibility' => 'scheme_mixes#allocate_project_team_responsibility', as: 'allocate_project_team_responsibility'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:id/allocate-certifier-team-responsibility' => 'scheme_mixes#allocate_certifier_team_responsibility', as: 'allocate_certifier_team_responsibility'

  resources :users
  get 'projects/:project_id/users/new' => 'users#new_member', as: 'new_project_user'
  get 'projects/:project_id/users/:id/tasks' => 'users#index_tasks', as: 'project_user_tasks'
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
