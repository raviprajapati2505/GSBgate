Rails.application.routes.draw do
  # You can have the root of your site routed with "root", root_path will be different by user role
  root to: 'users#index', constraints: RoleConstraint.new(:users_admin) #matches this route when the current user is an admin
  root to: 'projects#index'

  # devise_for :users
  devise_for :users, controllers: { registrations: 'users/registrations',
                                    sessions: 'users/sessions',
                                    invitations: 'users/invitations',
                                    passwords: 'users/passwords',
                                    confirmations: 'users/confirmations' }

  devise_scope :user do
    get '/users/registrations/new_service_provider', to: 'users/registrations#new_service_provider', as: :new_service_provider
    post '/users/registrations/create_service_provider', to: 'users/registrations#create_service_provider', as: :create_service_provider
    get '/users/registrations/:id/edit_service_provider', to: 'users/registrations#edit_service_provider', as: :edit_service_provider
    put '/users/registrations/:id/update_service_provider', to: 'users/registrations#update_service_provider', as: :update_service_provider
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes", or navigate to /rails/info

  # Our own "users/*" routes
  resources :users, only: [:index, :show] do
    collection do
      resource :sessions, only: [:new, :create, :destroy]
      get 'masquerade/:user_id' => 'users#masquerade', as: 'masquerade', constraints: { user_id: /\d+/ }
      get 'find_users_by_email/:email/:project_id(/:gord_employee)' => 'users#find_users_by_email', as: 'find_users_by_email', constraints: { email: /[^\/]+/ }
      get "country_cities", to: "users#country_cities", as: :country_cities
      get "get_organization_details", to: "users#get_organization_details", as: :get_organization_details
      get "get_service_provider_by_domain", to: "users#get_service_provider_by_domain", as: :get_service_provider_by_domain
      get "country_code_from_name", to: "users#country_code_from_name", as: :country_code_from_name
    end
    member do
      get :edit, to: 'users#edit', as: :edit
      put :update, to: 'users#update', as: :update
      get :edit_service_provider, to: 'users#edit_service_provider', as: :edit_service_provider
      put :update_service_provider, to: 'users#update_service_provider', as: :update_service_provider
      get :list_notifications, path: :notifications
      put :update_notifications, path: :notifications
      patch :update_user_status, to: 'users#update_user_status', as: 'update_user_status'
      get "download_user_files"
    end
  end

  # Main nested resources of our application
  resources :projects do
    collection do
      get 'list' => 'projects_users#list_projects'
      get 'country_locations', to: "projects#country_locations", as: :country_locations
      get 'country_city_districts', to: "projects#country_city_districts", as: :country_city_districts
    end
    member do
      get 'tools' => 'projects#show_tools'
      get 'confirm_destroy' => 'projects#confirm_destroy'
    end

    resources :project_rendering_images, only: [:create, :show, :destroy], path: :project_rendering_image
    resources :actual_project_images, only: [:create, :show, :destroy], path: :actual_project_image
    resources :projects_users, only: [:create, :edit, :show, :update, :destroy], path: :users, as: 'users', constraints: {id: /\d+/}
    resources :projects_surveys, only: [:new, :create, :edit, :show, :update, :destroy], path: :surveys, as: 'surveys', constraints: {id: /\d+/}
    resources :certification_paths, except: [:index, :edit, :update], path: :certificates do
      collection do
        get 'list'
      end

      member do
        # get :download_certificate_report
        get :new_detailed_certification_report
        post :create_detailed_certification_report
        get :download_coverletter_report
        get :download_detailed_certificate_report
        get :edit_status
        get :edit_project_team_responsibility_for_submittal, path: :edit_project_team_responsibility_for_submittal
        get :edit_certifier_team_responsibility_for_verification, path: :edit_certifier_team_responsibility_for_verification
        get :edit_certifier_team_responsibility_for_screening, path: :edit_certifier_team_responsibility_for_screening
        get :edit_main_scheme_mix, path: :edit_main_scheme_mix
        get :edit_max_review_count
        get :edit_expires_at
        get 'confirm_destroy' => 'certification_paths#confirm_destroy'
        get 'confirm_deny' => 'certification_paths#confirm_deny'
        get 'deny' => 'certification_paths#deny'
        get :download_signed_certificate
        put :update_status
        put :apply_for_pcr
        put :approve_pcr_payment
        put :cancel_pcr
        put :allocate_project_team_responsibility_for_submittal, path: :allocate_project_team_responsibility_for_submittal
        put :allocate_certifier_team_responsibility_for_verification, path: :allocate_certifier_team_responsibility_for_verification
        put :allocate_certifier_team_responsibility_for_screening, path: :allocate_certifier_team_responsibility_for_screening
        put :update_main_scheme_mix, path: :update_main_scheme
        put :update_max_review_count
        put :update_expires_at
        put :update_signed_certificate
        delete :remove_signed_certificate
      end
      resources :documents, only: [:create, :show, :destroy], path: :document
      resources :certification_path_documents, only: [:create, :show, :destroy], path: :certification_path_document
      resources :scheme_mixes, only: [:show, :edit, :update], path: :schemes do
        member do
          get :download_scores_report
        end
        resources :scheme_mix_criteria, only: [:show], path: :criteria, as: 'scheme_mix_criterion' do
          member do
            get :edit_status
            get :apply_pcr
            get :request_review
            get :provide_review_comment
            get :provide_draft_review_comment
            put :update_status
            put :add_review_comment
            put :add_draft_review_comment
            put :screen
            put :update_scores
            put :update_checklist
            put :assign_certifier
            post :upload_discrepancy_document
          end
          delete "delete_discrepancy_document/:id", to: "scheme_mix_criteria#delete_discrepancy_document", as: :delete_discrepancy_document

          resources :requirement_data, only: [:update], path: :requirement, as: 'requirement_data' do
            member do
              put :update_status
            end
          end
          resources :scheme_mix_criteria_documents, only: [], path: :documentation, as: 'scheme_mix_criteria_documents' do
            member do
              get :new_link
              post :create_link
              get :unlink
              post :destroy_link
              get :edit_status
              put :update_status
            end
          end
        end
      end
      resources :scheme_mix_criteria, only: [:list], path: :criteria do
        collection do
          get :list
        end
      end
    end
  end

  # survey related modules
  resources :survey_dashboard, only: [:index]
  resources :survey_types
  
  get 'survey_reponses/:survey_id' => 'survey_responses#new', as: 'survey_reponses_form'
  post 'survey_reponses_submit/:survey_id' => 'survey_responses#create', as: 'survey_reponses_submit'

  # Custom routes
  get 'projects/:id/location_plan' => 'projects#download_location_plan', as: 'download_project_location_plan'
  get 'projects/:id/site_plan' => 'projects#download_site_plan', as: 'download_project_site_plan'
  get 'projects/:id/design_brief' => 'projects#download_design_brief', as: 'download_project_design_brief'
  get 'projects/:id/narrative' => 'projects#download_project_narrative', as: 'download_project_narrative'
  get 'projects/:id/sustainability_features' => 'projects#download_sustainability_features', as: 'download_sustainability_features'
  get 'projects/:id/area_statement' => 'projects#download_area_statement', as: 'download_area_statement'
  
  resources :audit_logs, only: [:index], path: :audit_logs do
    collection do
      get 'export'
      get ':audit_log_id/link_smc_comments_form' => 'audit_logs#link_smc_comments_form', as: 'link_smc_audit_log_form'
      post ':audit_log_id/link_smc_comments' => 'audit_logs#link_smc_comments', as: 'link_smc_audit_log'
      get ':audit_log_id/unlink_smc_comments_form' => 'audit_logs#unlink_smc_comments_form', as: 'unlink_smc_audit_log_form'
      patch ':audit_log_id/unlink_smc_comments' => 'audit_logs#unlink_smc_comments', as: 'unlink_smc_audit_log'
    end
  end
  get 'audit-logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_index', as: 'auditable_index_logs'
  get 'audit-logs/:auditable_type/:auditable_id/comments' => 'audit_logs#auditable_index_comments', as: 'auditable_index_comments'
  get 'audit-logs/:auditable_type/:auditable_id/download-attachment/:id' => 'audit_logs#download_attachment', as: 'download_audit_log_attachment'
  post 'audit-logs/:auditable_type/:auditable_id' => 'audit_logs#auditable_create', as: 'auditable_create_audit_log'

  get 'tasks' => 'tasks#index', as: 'tasks'
  get 'tasks/user/:user_id' => 'tasks#count', as: 'count_tasks'
  match 'projects/:project_id/certificates/apply/:certification_type' => 'certification_paths#apply', as: 'apply_certification_path', via: [:get, :post]
  get 'projects/:project_id/certificates/:id/archive' => 'certification_paths#download_archive', as: 'archive_project_certification_path'
  get 'projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:id/archive' => 'scheme_mix_criteria#download_archive', as: 'archive_project_certification_path_scheme_mix_scheme_mix_criterion'
  get 'projects/:project_id/certificates/:id/comments' => 'certification_paths#download_comments', as: 'comments_project_cerficiation_path'
  get 'projects/users/:user_id' => 'projects_users#list_users_sharing_projects', as: 'list_users_sharing_projects'
  put '/projects/:project_id/certificates/:certification_path_id/schemes/:scheme_mix_id/criteria/:scheme_mix_criterion_id/requirement/:id/refuse' => 'requirement_data#refuse', as: 'refuse_requirement_datum'
  resources :requirements, only: [:edit, :update]
  resources :requirements, only: [:show], as: 'requirement'
  resources :scheme_criteria, only: [:index, :edit, :update]
  resources :scheme_criteria, only: [:show], as: 'scheme_criterion'
  resources :scheme_criterion_texts, only: [:edit, :update, :new, :create, :destroy] do
    put :sort, on: :collection
  end
  resources :scheme_categories, only: [:edit, :update] do
    put :sort, on: :collection
  end
  resources :scheme_categories, only: [:show], as: 'scheme_category'
  resources :schemes, only: [:edit, :update]
  resources :schemes, only: [:show], as: 'scheme'
  get 'owners/:id' => 'owners#show', as: 'owner'
  get 'owners' => 'owners#index', as: 'owners'
  # Reports
  get 'reports/certifiers_criteria' => 'reports#certifiers_criteria'
  resources :archives, only: [:show]

  # Error pages routes
  match '/403', to: 'errors#forbidden', via: :all, as: 'forbidden_error'
  match '/404', to: 'errors#not_found', via: :all, as: 'not_found_error'
  match '/422', to: 'errors#unprocessable_entity', via: :all, as: 'unprocessable_entity_error'
  match '/500', to: 'errors#internal_server_error', via: :all, as: 'internal_server_error_error'

  namespace :api, defaults: {format: 'json'} do
    devise_scope :user do
      post   'users/sign_in'  => '/api/sessions#create'
      delete 'users/sign_out' => '/api/sessions#destroy'
    end

    namespace :v1 do
      resources :projects, only: [:index, :show]
      get 'typologies' => 'projects#typologies', as: 'typologies'
      get 'building_type_groups' => 'projects#building_type_groups', as: 'building_type_groups'
      get 'building_types' => 'projects#building_types', as: 'building_types'
    end
  end

  # CATCH ALL ROUTE, redirecting the user to a correct page
  # BEWARE: this should be the last line, as it will match any path !!!
  # -- to avoid unknown routes to pollute the logs, use this:
  # match '*path', to: 'errors#not_found', via: :all unless Rails.env.development?
  # -- or to redirect the user to the main page, use this:
  #match '*path', to: 'projects#index', via: :all unless Rails.env.development?
end
