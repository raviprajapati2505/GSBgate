Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes", or navigate to /rails/info

  # You can have the root of your site routed with "root"
  root 'projects#index'

  # Devise "user/*" routes
  devise_for :user, skip: :registrations, :controllers => {:confirmations => 'confirmations'}
  devise_scope :user do
    resource :registration,
      only: [:new, :create, :edit, :update],
      path: 'user',
      path_names: { new: 'sign_up' },
      controller: 'registrations',
      as: :user_registration
  end
  as :user do
    patch '/user/confirmation' => 'confirmations#update', :via => :patch, :as => :update_user_confirmation
  end

  # Our own "users/*" routes
  resources :users do
      member do
        get 'list_notifications', path: 'notifications'
        put 'update_notifications', path: 'notifications'
      end
  end

  # proxy all requests to the external api
  match 'ssApi', to: 'tools#proxy', via: :all
  match 'ssApi/*segment', to: 'tools#proxy', via: :all

  # Main nested resources of our application
  resources :projects, except: [:destroy] do
    collection do
      get 'list' => 'projects_users#list_projects'
    end
    member do
      get 'tools' => 'projects#show_tools'
    end
    resources :projects_users, only: [:create, :edit, :show, :update, :destroy], path: 'users', as: 'users', constraints: {id: /\d+/} do
      collection do
        get 'available/:role' => 'projects_users#available', as: 'available', default: {role: 'all'}, constraints: {role: /all|certifier|assessor|enterprise_client/}
      end
    end
    resources :certification_paths, except: [:index, :edit, :destroy, :update], path: 'certificates' do
      collection do
        get 'list'
      end
      member do
        get 'download_certificate_report' => 'reports#download_certificate', as: 'download_certificate_report'
        get 'download_coverletter_report' => 'reports#download_certificate_coverletter', as: 'download_coverletter_report'
        get 'download_scores_report' => 'reports#download_certificate_scores', as: 'download_scores_report'
        get 'edit_status'
        get 'edit_project_team_responsibility', path: 'edit-project-team-responsibility'
        get 'edit_certifier_team_responsibility', path: 'edit-certifier-team-responsibility'
        put 'update_status'
        put 'apply_for_pcr'
        put 'approve_pcr_payment'
        put 'allocate_project_team_responsibility', path: 'allocate-project-team-responsibility'
        put 'allocate_certifier_team_responsibility', path: 'allocate-certifier-team-responsibility'
      end
      resources :documents, only: [:create, :show], path: 'document'
      resources :scheme_mixes, only: [:show], path: 'schemes' do
        resources :scheme_mix_criteria, only: [:show], path: 'criteria', as: 'scheme_mix_criterion' do
          member do
            get 'edit_status'
            put 'update_status'
            put 'update_scores'
            put 'assign_certifier'
          end
          resources :requirement_data, only: [:update], path: 'requirement', as: 'requirement_data' do
            member do
              put 'update_status'
            end
          end
          resources :scheme_mix_criteria_documents, only: [], path: 'documentation', as: 'scheme_mix_criteria_documents' do
            member do
              get 'new_link'
              post 'create_link'
              get 'edit_status'
              put 'update_status'
            end
          end
        end
      end
      resources :scheme_mix_criteria, only: [:list], path: 'criteria' do
        collection do
          get 'list'
        end
      end
    end
  end

  # Custom routes
  get 'projects/:id/location_plan' => 'projects#download_location_plan', as: 'download_project_location_plan'
  get 'projects/:id/site_plan' => 'projects#download_site_plan', as: 'download_project_site_plan'
  get 'projects/:id/design_brief' => 'projects#download_design_brief', as: 'download_project_design_brief'
  get 'projects/:id/narrative' => 'projects#download_project_narrative', as: 'download_project_narrative'
  resources :audit_logs, only: [:index], path: 'audit-logs'
  get 'audit-logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_index', as: 'auditable_index_logs'
  get 'audit-logs/:auditable_type/:auditable_id/comments' => 'audit_logs#auditable_index_comments', as: 'auditable_index_comments'
  post 'audit-logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_create', as: 'auditable_create_audit_log'
  get 'tasks' => 'tasks#index', as: 'tasks'
  get 'tasks/user/:user_id' => 'tasks#count', as: 'count_tasks'
  match 'projects/:project_id/certificates/apply/:certificate_id' => 'certification_paths#apply', as: 'apply_certification_path', via: [:get, :post]
  get 'projects/:project_id/certificates/:id/archive' => 'certification_paths#download_archive', as: 'archive_project_certification_path'
  get 'projects/:project_id/certificates/:id/comments' => 'certification_paths#download_comments', as: 'comments_project_cerficiation_path'
  get 'projects/users/:user_id' => 'projects_users#list_users_sharing_projects', as: 'list_users_sharing_projects'
  post 'projects/:project_id/users/:id' => 'projects_users#make_owner', as: 'make_owner'
  put '/projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:scheme_mix_criterion_id/requirement/:id/refuse' => 'requirement_data#refuse', as: 'refuse_requirement_datum'
  resources :scheme_criteria, only: [:index]
  resources :scheme_criteria, only: [:show], as: 'scheme_criterion'
  resources :scheme_criterion_texts, only: [:edit, :update, :new, :create, :destroy] do
    put :sort, on: :collection
  end

  # Error pages routes
  match '/403', to: 'errors#forbidden', via: :all, as: 'forbidden_error'
  match '/404', to: 'errors#not_found', via: :all, as: 'not_found_error'
  match '/422', to: 'errors#unprocessable_entity', via: :all, as: 'unprocessable_entity_error'
  match '/500', to: 'errors#internal_server_error', via: :all, as: 'internal_server_error_error'

  # CATCH ALL ROUTE, redirecting the user to a correct page
  # BEWARE: this should be the last line, as it will match any path !!!
  # -- to avoid unknown routes to pollute the logs, use this:
  match '*path', to: 'errors#not_found', via: :all unless Rails.env.development?
  # -- or to redirect the user to the main page, use this:
  #match '*path', to: 'projects#index', via: :all unless Rails.env.development?
end
