Rails.application.routes.draw do
  # You can have the root of your site routed with "root", root_path will be different by user role
  # root to: 'users#index', constraints: RoleConstraint.new(:users_admin) # matches this route when the current user is an admin
  root to: 'projects#index'

  # devise_for :users
  devise_for :users, controllers: { registrations: 'users/registrations',
                                    sessions: 'users/sessions',
                                    invitations: 'users/invitations',
                                    passwords: 'users/passwords',
                                    confirmations: 'users/confirmations' }

  devise_scope :user do
    get '/users/registrations/new_corporate', to: 'users/registrations#new_corporate', as: :new_corporate
    post '/users/registrations/create_corporate', to: 'users/registrations#create_corporate', as: :create_corporate
    get '/users/registrations/:id/edit_corporate', to: 'users/registrations#edit_corporate', as: :edit_corporate
    put '/users/registrations/:id/update_corporate', to: 'users/registrations#update_corporate', as: :update_corporate
    post '/users/sessions/check_authentication', to: 'users/sessions#check_authentication'
    post '/users/sessions/validate_otp/:id', to: 'users/sessions#validate_otp', as: :validate_otp
    get '/users/sessions/otp/:id', to: 'users/sessions#otp', as: :send_otp
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes", or navigate to /rails/info

  # Our own "users/*" routes
  resources :users, only: [:index, :show, :destroy] do
    collection do
      resource :sessions, only: [:new, :create, :destroy]
      get 'masquerade/:user_id' => 'users#masquerade', as: 'masquerade', constraints: { user_id: /\d+/ }
      get 'find_users_by_email/:email/:project_id(/:gord_employee)' => 'users#find_users_by_email', as: 'find_users_by_email', constraints: { email: /[^\/]+/ }
      get "country_cities", to: "users#country_cities", as: :country_cities
      get "get_organization_details", to: "users#get_organization_details", as: :get_organization_details
      get "get_corporate_by_domain", to: "users#get_corporate_by_domain", as: :get_corporate_by_domain
      get "get_corporate_by_email", to: "users#get_corporate_by_email", as: :get_corporate_by_email
      get "country_code_from_name", to: "users#country_code_from_name", as: :country_code_from_name
    end
    member do
      get :edit, to: 'users#edit', as: :edit
      put :update, to: 'users#update', as: :update
      get :edit_corporate, to: 'users#edit_corporate', as: :edit_corporate
      put :update_corporate, to: 'users#update_corporate', as: :update_corporate
      get :list_notifications, path: :notifications
      put :update_notifications, path: :notifications
      patch :update_user_status, to: 'users#update_user_status', as: 'update_user_status'
      get "download_user_files"
      get "increase_demerit_flag", to: 'users#increase_demerit_flag'
      get 'confirm_destroy', to: 'users#confirm_destroy_cgp_user'
    end
  end

  # Main nested resources of our application
  resources :projects do
    collection do
      get 'list' => 'projects_users#list_projects'
      get 'country_locations', to: "projects#country_locations", as: :country_locations
      get 'country_city_districts', to: "projects#country_city_districts", as: :country_city_districts
      get 'projects_statistics', to: "projects#projects_statistics", as: :projects_statistics
    end
    member do
      get 'tools' => 'projects#show_tools'
      get 'confirm_destroy' => 'projects#confirm_destroy'
    end

    resources :project_rendering_images, only: [:create, :show, :destroy], path: :project_rendering_image
    resources :actual_project_images, only: [:create, :show, :destroy], path: :actual_project_image
    resources :projects_users, only: [:create, :edit, :show, :update, :destroy], path: :users, as: 'users', constraints: {id: /\d+/}
    resources :projects_surveys, except: [:index], path: :surveys, as: 'surveys', constraints: {id: /\d+/} do
      member do
        get :copy_project_survey
        get :export_survey_results
        get :export_excel_survey_results
      end
    end
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
  resources :survey_dashboard, only: [:index] do
    collection do
      get 'total_project_surveys', to: 'survey_dashboard#total_project_surveys', as: 'total_project_surveys'
    end
  end
  resources :survey_types do
    resources :survey_questionnaire_versions, only: [:show] do
      collection do
        get :form
        post :create
        patch :update
        patch :update_position
      end
    end
  end
  resources :survey_questions
  resources :survey_responses, only: [] do 
    collection do
      get ':project_survey_id/new', to: 'survey_responses#new', as: 'form'
      post ':project_survey_id/create', to: 'survey_responses#create', as: 'submit'
      get ':project_survey_id/thank_you', to: 'survey_responses#thank_you', as: 'thank_you'
      get 'all_text_responses_of_survey_question', to: 'survey_responses#all_text_responses_of_survey_question', as: 'all_text_responses_of_survey_question'
    end
  end
  get 'linkme_surveys', to: 'linkme_surveys#index', as: 'linkme_surveys'
  get 'linkme_surveys/:id/download_linkme_survey_data' => 'linkme_surveys#download_linkme_survey_data', as: 'download_linkme_survey_data'

  # Custom routes
  get 'projects/:id/location_plan' => 'projects#download_location_plan', as: 'download_project_location_plan'
  get 'projects/:id/site_plan' => 'projects#download_site_plan', as: 'download_project_site_plan'
  get 'projects/:id/design_brief' => 'projects#download_design_brief', as: 'download_project_design_brief'
  get 'projects/:id/narrative' => 'projects#download_project_narrative', as: 'download_project_narrative'
  get 'projects/:id/sustainability_features' => 'projects#download_sustainability_features', as: 'download_sustainability_features'
  get 'projects/:id/area_statement' => 'projects#download_area_statement', as: 'download_area_statement'
  get 'projects_surveys/index' => 'projects_surveys#index', as: 'projects_surveys'

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
  get 'confirm_destroy/:task_id' => 'tasks#confirm_destroy', as: 'destroy_task'
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
      resources :countries
    end
  end

  # routes.rb
  namespace :offline do
    resources :projects do
      collection do
        get ':document_id/download_document', to: 'projects#download_document', as: :download_document
        delete ':document_id/destroy_document', to: 'projects#destroy_document', as: :destroy_document
      end

      member do
        get :confirm_destroy
        post :upload_documents
      end

      resources :certification_paths, path: :certification, as: 'certification' do
        member do
          get 'confirm_destroy', to: 'certification_paths#confirm_destroy'
          get :download_signed_certificate
          put :update_signed_certificate
          delete :remove_signed_certificate
        end

        resources :scheme_mixes, only: [:show, :create, :new], path: :scheme_mix, as: 'schemes' do
          member do
            get 'edit_criterion', to: 'scheme_mixes#edit_criterion'
            put 'update_criterion', to: 'scheme_mixes#update_criterion'
          end
        end
      end
    end
  end

  get 'dashboard' => 'dashboard#index', as: 'dashboard'
  get 'dashboard/:user_id' => 'dashboard#index', as: 'dashboard_user'
  post 'upload_document' => 'dashboard#upload_document'
  get 'confirm_destroy_demerit/:demerit_id' => 'dashboard#confirm_destroy_demerit', as: 'demerits'

  # CATCH ALL ROUTE, redirecting the user to a correct page
  # BEWARE: this should be the last line, as it will match any path !!!
  # -- to avoid unknown routes to pollute the logs, use this:
  # match '*path', to: 'errors#not_found', via: :all unless Rails.env.development?
  # -- or to redirect the user to the main page, use this:
  #match '*path', to: 'projects#index', via: :all unless Rails.env.development?
end
