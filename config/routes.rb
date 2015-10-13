Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes", or navigate to /rails/info

  # You can have the root of your site routed with "root"
  root 'projects#index'

  # Login resource
  resources :users
  devise_for :user

  # Main nested resources of our application
  resources :projects, except: [ :destroy ] do
    member do
      get 'tools' => 'projects#show_tools'
    end
    resources :projects_users, only: [ :create, :edit, :show, :update, :destroy ], path: 'users', as: 'users'
    resources :certification_paths, except: [ :index, :edit, :destroy, :update], path: 'certificates' do
      collection do
        get 'list'
      end
      member do
        get 'download_certificate_report' => 'reports#download_certificate', as: 'download_certificate_report'
        get 'download_coverletter_report' => 'reports#download_certificate_coverletter', as: 'download_coverletter_report'
        get 'download_scores_report' => 'reports#download_certificate_scores', as: 'download_scores_report'
      end
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
  get 'projects/:id/location_plan' => 'projects#download_location_plan', as: 'download_project_location_plan'
  get 'projects/:id/site_plan' => 'projects#download_site_plan', as: 'download_project_site_plan'
  get 'projects/:id/design_brief' => 'projects#download_design_brief', as: 'download_project_design_brief'
  get 'projects/:id/narrative' => 'projects#download_project_narrative', as: 'download_project_narrative'
  resources :audit_logs, only: [ :index ], path: 'audit-logs'
  get 'audit-logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_index', as: 'auditable_index_audit_logs'
  post 'audit-logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_create', as: 'auditable_create_audit_log'
  get 'tasks' => 'tasks#index', as: 'tasks'
  match 'projects/:project_id/certificates/apply/:certificate_id' => 'certification_paths#apply', as: 'apply_certification_path', via: [:get, :post]
  put 'projects/:project_id/certificates/:id/update-approvals' => 'certification_paths#update_approvals', as: 'update_certification_path_approvals'
  put 'projects/:project_id/certificates/:id/update-status' => 'certification_paths#update_status', as: 'update_certification_path_status'
  put 'projects/:project_id/certificates/:id/update-pcr' => 'certification_paths#update_pcr', as: 'update_certification_path_pcr'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:id/assign' => 'scheme_mix_criteria#assign_certifier', as: 'assign_certifier_to_criteria'
  get 'projects/:project_id/certificates/:id/archive' => 'certification_paths#download_archive', as: 'archive_project_certification_path'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:id/allocate-project-team-responsibility' => 'scheme_mixes#allocate_project_team_responsibility', as: 'allocate_project_team_responsibility'
  put 'projects/:project_id/certificates/:certification_path_id/schemes/:id/allocate-certifier-team-responsibility' => 'scheme_mixes#allocate_certifier_team_responsibility', as: 'allocate_certifier_team_responsibility'
  get 'projects/:project_id/users' => 'projects_users#list_unauthorized_users', as: 'list_unauthorized_users'
  get 'projects/users/:user_id' => 'projects_users#list_users_sharing_projects', as: 'list_users_sharing_projects'
  put '/projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:scheme_mix_criterion_id/requirement/:id/refuse' => 'requirement_data#refuse', as: 'refuse_requirement_datum'
  resources :scheme_criteria, only: [ :index ]
  resources :scheme_criteria, only: [ :show ], as: 'scheme_criterion'
  resources :scheme_criterion_texts, only: [:edit, :update, :new, :create, :destroy] do
    put :sort, on: :collection
  end

  # Generic Error pages
  match '/403', to: 'errors#forbidden', via: :all, as: 'forbidden_error'
  match '/404', to: 'errors#not_found', via: :all, as: 'not_found_error'
  match '/422', to: 'errors#unprocessable_entity', via: :all, as: 'unprocessable_entity_error'
  match '/500', to: 'errors#internal_server_error', via: :all, as: 'internal_server_error_error'

  # CATCH ALL ROUTE, redirecting the user to a correct page
  # BEWARE: this should be the last line, as it will match any path !!!
  # -- to avoid unknown routes to pollute the logs, use this:
  match '*path', to: 'errors#not_found', via: :all, as: 'not_found_error' unless Rails.env.development?
  # -- or to redirect the user to the main page, use this:
  #match '*path', to: 'projects#index', via: :all, as: 'not_found_error' unless Rails.env.development?
end
