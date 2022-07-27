# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_07_25_085024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_licences", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "licence_id"
    t.date "expiry_date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["licence_id"], name: "index_access_licences_on_licence_id"
    t.index ["user_id", "licence_id"], name: "index_access_licences_on_user_id_and_licence_id"
    t.index ["user_id"], name: "index_access_licences_on_user_id"
  end

  create_table "actual_project_images", force: :cascade do |t|
    t.string "actual_image"
    t.bigint "certification_path_id"
    t.bigint "project_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["certification_path_id"], name: "index_actual_project_images_on_certification_path_id"
    t.index ["project_id"], name: "index_actual_project_images_on_project_id"
  end

  create_table "archives", id: :serial, force: :cascade do |t|
    t.string "archive_file"
    t.integer "status"
    t.integer "subject_id"
    t.string "subject_type"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "criterion_document_ids", default: [], array: true
    t.boolean "all_criterion_document", default: false
    t.index ["subject_type", "subject_id"], name: "index_archives_on_subject_type_and_subject_id"
    t.index ["user_id"], name: "index_archives_on_user_id"
  end

  create_table "audit_log_visibilities", id: :serial, force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "audit_logs", id: :serial, force: :cascade do |t|
    t.text "system_message"
    t.text "user_comment"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "new_status"
    t.integer "old_status"
    t.integer "certification_path_id"
    t.integer "audit_log_visibility_id"
    t.string "attachment_file"
    t.index ["audit_log_visibility_id"], name: "index_audit_logs_on_audit_log_visibility_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["project_id"], name: "index_audit_logs_on_project_id"
    t.index ["system_message"], name: "index_audit_logs_on_system_message"
    t.index ["user_comment"], name: "index_audit_logs_on_user_comment"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "background_executions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "building_type_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "visible", default: true
  end

  create_table "building_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "building_type_group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "visible", default: true
    t.index ["building_type_group_id"], name: "index_building_types_on_building_type_group_id"
  end

  create_table "calculator_data", id: :serial, force: :cascade do |t|
    t.integer "calculator_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["calculator_id"], name: "index_calculator_data_on_calculator_id"
  end

  create_table "calculators", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "certificates", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "certificate_type"
    t.integer "assessment_stage"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "display_weight"
    t.string "gsas_version"
    t.integer "certification_type"
  end

  create_table "certification_path_methods", force: :cascade do |t|
    t.bigint "certification_path_id"
    t.integer "assessment_method"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["certification_path_id"], name: "index_certification_path_methods_on_certification_path_id"
  end

  create_table "certification_path_reports", force: :cascade do |t|
    t.bigint "certification_path_id"
    t.string "reference_number"
    t.string "to"
    t.string "project_owner"
    t.string "project_name"
    t.string "project_location"
    t.date "issuance_date"
    t.date "approval_date"
    t.datetime "release_date", precision: nil
    t.boolean "is_released", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["certification_path_id"], name: "index_certification_path_reports_on_certification_path_id"
  end

  create_table "certification_path_statuses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "past_name"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "certification_paths", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "certificate_id"
    t.boolean "pcr_track", default: false
    t.datetime "started_at", precision: nil
    t.integer "certification_path_status_id"
    t.boolean "appealed", default: false
    t.datetime "certified_at", precision: nil
    t.integer "main_scheme_mix_id"
    t.boolean "main_scheme_mix_selected", default: false, null: false
    t.integer "max_review_count", default: 2
    t.integer "development_type_id"
    t.string "signed_certificate_file"
    t.boolean "show_all_criteria", default: true
    t.datetime "expires_at", precision: nil
    t.integer "buildings_number", default: 0
    t.index ["certification_path_status_id"], name: "index_certification_paths_on_certification_path_status_id"
    t.index ["development_type_id"], name: "index_certification_paths_on_development_type_id"
    t.index ["main_scheme_mix_id"], name: "index_certification_paths_on_main_scheme_mix_id"
    t.index ["project_id"], name: "index_certification_paths_on_project_id"
  end

  create_table "development_type_schemes", id: :serial, force: :cascade do |t|
    t.integer "development_type_id"
    t.integer "scheme_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["development_type_id"], name: "index_development_type_schemes_on_development_type_id"
    t.index ["scheme_id"], name: "index_development_type_schemes_on_scheme_id"
  end

  create_table "development_types", id: :serial, force: :cascade do |t|
    t.integer "certificate_id"
    t.string "name"
    t.integer "display_weight"
    t.boolean "mixable"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["certificate_id"], name: "index_development_types_on_certificate_id"
  end

  create_table "districts", force: :cascade do |t|
    t.text "list", default: [], array: true
    t.string "country"
    t.string "city"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "document_file"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "store_dir"
    t.string "type"
    t.integer "certification_path_id"
    t.bigint "certification_path_status_id"
    t.index ["certification_path_id"], name: "index_documents_on_certification_path_id"
    t.index ["certification_path_status_id"], name: "index_documents_on_certification_path_status_id"
    t.index ["user_id"], name: "by_user"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "field_data", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.string "string_value"
    t.integer "integer_value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "calculator_datum_id"
    t.string "type"
    t.index ["field_id"], name: "index_field_data_on_field_id"
  end

  create_table "fields", id: :serial, force: :cascade do |t|
    t.integer "calculator_id"
    t.string "name"
    t.string "machine_name"
    t.string "datum_type"
    t.string "validation"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "required"
    t.text "help_text"
    t.string "prefix"
    t.string "suffix"
    t.index ["calculator_id"], name: "index_fields_on_calculator_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", precision: nil, null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "licences", force: :cascade do |t|
    t.string "licence_type"
    t.integer "display_weight", default: 0
    t.string "display_name"
    t.string "title"
    t.string "description"
    t.integer "certificate_type"
    t.integer "time_period"
    t.integer "applicability", default: 3
    t.text "schemes", default: [], array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "linkme_surveys", force: :cascade do |t|
    t.string "title"
    t.string "status"
    t.string "link"
    t.string "user_access"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "country"
    t.text "list", default: [], array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "notification_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "project_level"
  end

  create_table "notification_types_users", id: :serial, force: :cascade do |t|
    t.integer "notification_type_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "project_id"
    t.index ["notification_type_id"], name: "index_notification_types_users_on_notification_type_id"
    t.index ["project_id"], name: "index_notification_types_users_on_project_id"
    t.index ["user_id"], name: "index_notification_types_users_on_user_id"
  end

  create_table "offline_certification_paths", force: :cascade do |t|
    t.bigint "offline_project_id"
    t.string "name"
    t.integer "version"
    t.string "development_type"
    t.string "certified_at"
    t.string "status"
    t.integer "rating"
    t.string "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offline_project_id"], name: "index_offline_certification_paths_on_offline_project_id"
  end

  create_table "offline_project_documents", force: :cascade do |t|
    t.bigint "offline_project_id"
    t.string "document_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offline_project_id"], name: "index_offline_project_documents_on_offline_project_id"
  end

  create_table "offline_projects", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "certified_area"
    t.string "site_area"
    t.integer "certificate_type"
    t.string "developer"
    t.string "construction_year"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offline_scheme_mix_criterion", force: :cascade do |t|
    t.bigint "offline_scheme_mix_id"
    t.string "name"
    t.string "code"
    t.decimal "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offline_scheme_mix_id"], name: "index_offline_scheme_mix_criterion_on_offline_scheme_mix_id"
  end

  create_table "offline_scheme_mixes", force: :cascade do |t|
    t.bigint "offline_certification_path_id"
    t.string "name"
    t.decimal "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offline_certification_path_id"], name: "index_offline_scheme_mixes_on_offline_certification_path_id"
  end

  create_table "owners", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "governmental"
    t.boolean "private_developer"
    t.boolean "private_owner"
  end

  create_table "project_rendering_images", force: :cascade do |t|
    t.string "rendering_image"
    t.bigint "certification_path_id"
    t.bigint "project_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["certification_path_id"], name: "index_project_rendering_images_on_certification_path_id"
    t.index ["project_id"], name: "index_project_rendering_images_on_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.text "address"
    t.string "location"
    t.string "country"
    t.integer "gross_area"
    t.integer "certified_area"
    t.integer "carpark_area"
    t.integer "project_site_area"
    t.string "code"
    t.integer "construction_year"
    t.string "location_plan_file"
    t.string "site_plan_file"
    t.string "design_brief_file"
    t.string "project_narrative_file"
    t.string "owner", default: "", null: false
    t.string "service_provider", default: "", null: false
    t.string "developer"
    t.integer "building_type_group_id"
    t.integer "building_type_id"
    t.integer "certificate_type"
    t.string "service_provider_2"
    t.string "estimated_project_cost"
    t.string "cost_square_meter"
    t.string "estimated_building_cost"
    t.string "estimated_infrastructure_cost"
    t.string "coordinates"
    t.integer "buildings_footprint_area"
    t.string "sustainability_features_file"
    t.string "area_statement_file"
    t.string "city"
    t.string "district"
    t.index ["building_type_group_id"], name: "index_projects_on_building_type_group_id"
    t.index ["building_type_id"], name: "index_projects_on_building_type_id"
  end

  create_table "projects_surveys", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "survey_type_id"
    t.string "title"
    t.integer "status"
    t.date "end_date"
    t.integer "user_access"
    t.string "description"
    t.string "submission_statement"
    t.datetime "released_at", precision: nil
    t.string "slug"
    t.bigint "survey_questionnaire_version_id"
    t.index ["project_id"], name: "index_projects_surveys_on_project_id"
    t.index ["slug"], name: "index_projects_surveys_on_slug", unique: true
    t.index ["survey_questionnaire_version_id"], name: "index_projects_surveys_on_survey_questionnaire_version_id"
    t.index ["survey_type_id"], name: "index_projects_surveys_on_survey_type_id"
  end

  create_table "projects_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "role"
    t.integer "certification_team_type", default: 0
    t.index ["project_id"], name: "index_projects_users_on_project_id"
    t.index ["user_id"], name: "index_projects_users_on_user_id"
  end

  create_table "question_options", force: :cascade do |t|
    t.integer "position", default: 0
    t.text "option_text"
    t.float "score", default: 0.0
    t.bigint "survey_question_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["survey_question_id"], name: "index_question_options_on_survey_question_id"
  end

  create_table "question_responses", force: :cascade do |t|
    t.string "value"
    t.bigint "survey_question_id"
    t.bigint "survey_response_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["survey_question_id"], name: "index_question_responses_on_survey_question_id"
    t.index ["survey_response_id"], name: "index_question_responses_on_survey_response_id"
  end

  create_table "requirement_data", id: :serial, force: :cascade do |t|
    t.integer "calculator_datum_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "requirement_id"
    t.integer "status"
    t.integer "user_id"
    t.date "due_date"
    t.index ["user_id"], name: "index_requirement_data_on_user_id"
  end

  create_table "requirements", id: :serial, force: :cascade do |t|
    t.integer "calculator_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.integer "display_weight"
  end

  create_table "scheme_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code", limit: 4
    t.text "description"
    t.text "impacts"
    t.text "mitigate_impact"
    t.integer "scheme_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "display_weight"
    t.boolean "shared", default: false, null: false
    t.boolean "is_checklist", default: false, null: false
    t.index ["code", "scheme_id"], name: "index_scheme_categories_on_code_and_scheme_id", unique: true
    t.index ["code"], name: "index_scheme_categories_on_code"
    t.index ["scheme_id"], name: "index_scheme_categories_on_scheme_id"
  end

  create_table "scheme_criteria", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "weight_a", precision: 5, scale: 2
    t.string "name"
    t.integer "number"
    t.string "scores_a"
    t.integer "scheme_category_id"
    t.decimal "minimum_score_a", precision: 4, scale: 1, null: false
    t.decimal "maximum_score_a", precision: 4, scale: 1, null: false
    t.decimal "minimum_valid_score_a", precision: 4, scale: 1, null: false
    t.decimal "incentive_weight_minus_1_a", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_0_a", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_1_a", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_2_a", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_3_a", precision: 5, scale: 2, default: "0.0"
    t.boolean "calculate_incentive_a", default: true
    t.boolean "assign_incentive_manually_a", default: false
    t.decimal "weight_b", precision: 5, scale: 2, default: "0.0"
    t.string "scores_b"
    t.decimal "minimum_score_b", precision: 4, scale: 1
    t.decimal "maximum_score_b", precision: 4, scale: 1
    t.decimal "minimum_valid_score_b", precision: 4, scale: 1
    t.decimal "incentive_weight_minus_1_b", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_0_b", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_1_b", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_2_b", precision: 5, scale: 2, default: "0.0"
    t.decimal "incentive_weight_3_b", precision: 5, scale: 2, default: "0.0"
    t.boolean "calculate_incentive_b", default: false
    t.boolean "assign_incentive_manually_b", default: false
    t.string "label_a"
    t.string "label_b"
    t.boolean "shared", default: true, null: false
    t.boolean "is_checklist", default: false, null: false
    t.index ["number"], name: "index_scheme_criteria_on_number"
    t.index ["scheme_category_id", "name"], name: "index_scheme_criteria_on_scheme_category_id_and_name", unique: true
    t.index ["scheme_category_id", "number"], name: "index_scheme_criteria_on_scheme_category_id_and_number", unique: true
    t.index ["scheme_category_id"], name: "index_scheme_criteria_on_scheme_category_id"
  end

  create_table "scheme_criteria_requirements", id: :serial, force: :cascade do |t|
    t.integer "scheme_criterion_id"
    t.integer "requirement_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["requirement_id"], name: "index_scheme_criteria_requirements_on_requirement_id"
    t.index ["scheme_criterion_id"], name: "index_scheme_criteria_requirements_on_scheme_criterion_id"
  end

  create_table "scheme_criterion_boxes", force: :cascade do |t|
    t.bigint "scheme_criterion_id"
    t.string "label"
    t.integer "display_weight"
    t.boolean "is_checked"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["scheme_criterion_id"], name: "index_scheme_criterion_boxes_on_scheme_criterion_id"
  end

  create_table "scheme_criterion_incentives", force: :cascade do |t|
    t.bigint "scheme_criterion_id"
    t.decimal "incentive_weight", precision: 5, scale: 2, default: "0.0"
    t.string "label"
    t.integer "display_weight"
    t.index ["scheme_criterion_id"], name: "index_incentives_to_scheme_criteria"
  end

  create_table "scheme_criterion_performance_labels", force: :cascade do |t|
    t.bigint "scheme_criterion_id"
    t.string "type", null: false
    t.string "label"
    t.integer "display_weight", default: 0
    t.string "levels", default: "---\n- 0\n- 1\n- 2\n- 3\n"
    t.string "bands", default: "---\n- A*\n- A\n- B\n- C\n- D\n- E\n- F\n- G\n"
    t.index ["scheme_criterion_id"], name: "index_perf_labels_to_scheme_criteria"
  end

  create_table "scheme_criterion_texts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "html_text"
    t.integer "display_weight"
    t.boolean "visible"
    t.integer "scheme_criterion_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "scheme_criterion_id"], name: "index_scheme_criterion_texts_on_name_and_scheme_criterion_id", unique: true
    t.index ["scheme_criterion_id"], name: "index_scheme_criterion_texts_on_scheme_criterion_id"
  end

  create_table "scheme_mix_criteria", id: :serial, force: :cascade do |t|
    t.integer "scheme_mix_id"
    t.integer "scheme_criterion_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status"
    t.integer "certifier_id"
    t.date "due_date"
    t.decimal "targeted_score_a", precision: 4, scale: 1
    t.decimal "submitted_score_a", precision: 4, scale: 1
    t.decimal "achieved_score_a", precision: 4, scale: 1
    t.integer "main_scheme_mix_criterion_id"
    t.boolean "in_review", default: false
    t.integer "review_count", default: 0
    t.boolean "incentive_scored_a", default: false
    t.boolean "screened", default: false, null: false
    t.text "pcr_review_draft"
    t.decimal "targeted_score_b", precision: 3, scale: 1
    t.decimal "submitted_score_b", precision: 3, scale: 1
    t.decimal "achieved_score_b", precision: 3, scale: 1
    t.boolean "incentive_scored_b", default: false
    t.boolean "epc_matches_energy_suite"
    t.index ["certifier_id"], name: "index_scheme_mix_criteria_on_certifier_id"
    t.index ["main_scheme_mix_criterion_id"], name: "index_scheme_mix_criteria_on_main_scheme_mix_criterion_id"
    t.index ["scheme_criterion_id"], name: "index_scheme_mix_criteria_on_scheme_criterion_id"
    t.index ["scheme_mix_id"], name: "index_scheme_mix_criteria_on_scheme_mix_id"
  end

  create_table "scheme_mix_criteria_documents", id: :serial, force: :cascade do |t|
    t.integer "scheme_mix_criterion_id"
    t.integer "document_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status"
    t.string "pcr_context"
    t.datetime "approved_date", precision: nil
    t.integer "document_type", default: 0
    t.index ["document_id"], name: "index_scheme_mix_criteria_documents_on_document_id"
    t.index ["scheme_mix_criterion_id", "document_id"], name: "scheme_mix_criteria_documents_unique", unique: true
    t.index ["scheme_mix_criterion_id"], name: "index_scheme_mix_criteria_documents_on_scheme_mix_criterion_id"
  end

  create_table "scheme_mix_criteria_requirement_data", id: :serial, force: :cascade do |t|
    t.integer "scheme_mix_criterion_id"
    t.integer "requirement_datum_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["requirement_datum_id"], name: "by_requirement_datum"
    t.index ["scheme_mix_criterion_id"], name: "by_scheme_mix_criterion"
  end

  create_table "scheme_mix_criterion_boxes", force: :cascade do |t|
    t.bigint "scheme_mix_criterion_id"
    t.bigint "scheme_criterion_box_id"
    t.boolean "is_checked"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["scheme_criterion_box_id"], name: "index_scheme_mix_criterion_boxes_on_scheme_criterion_box_id"
    t.index ["scheme_mix_criterion_id"], name: "index_scheme_mix_criterion_boxes_on_scheme_mix_criterion_id"
  end

  create_table "scheme_mix_criterion_incentives", force: :cascade do |t|
    t.bigint "scheme_mix_criterion_id"
    t.bigint "scheme_criterion_incentive_id"
    t.boolean "incentive_scored", default: false
    t.index ["scheme_criterion_incentive_id"], name: "index_incentives_to_scheme_criterion_incentives"
    t.index ["scheme_mix_criterion_id"], name: "index_incentives_to_scheme_mix_criteria"
  end

  create_table "scheme_mix_criterion_performance_labels", force: :cascade do |t|
    t.bigint "scheme_mix_criterion_id"
    t.bigint "scheme_criterion_performance_labels_id"
    t.string "type", null: false
    t.integer "level"
    t.string "band"
    t.decimal "epc"
    t.decimal "wpc"
    t.decimal "cooling"
    t.decimal "lighting"
    t.decimal "auxiliaries"
    t.decimal "dhw"
    t.decimal "others"
    t.decimal "generation"
    t.decimal "indoor_use"
    t.decimal "irrigation"
    t.decimal "cooling_tower"
    t.decimal "co2_emission"
    t.index ["scheme_criterion_performance_labels_id"], name: "index_perf_labels_to_scheme_criterion_perf_labels"
    t.index ["scheme_mix_criterion_id"], name: "index_perf_labels_to_scheme_mix_criteria"
  end

  create_table "scheme_mixes", id: :serial, force: :cascade do |t|
    t.integer "certification_path_id"
    t.integer "weight"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "scheme_id"
    t.string "custom_name"
    t.index ["certification_path_id", "scheme_id", "custom_name"], name: "ui_custom_name_scheme", unique: true
    t.index ["certification_path_id"], name: "index_scheme_mixes_on_certification_path_id"
  end

  create_table "schemes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "gsas_version"
    t.boolean "renovation", default: false, null: false
    t.string "gsas_document"
    t.integer "certificate_type"
    t.integer "certification_type"
  end

  create_table "service_provider_details", force: :cascade do |t|
    t.bigint "service_provider_id"
    t.string "business_field"
    t.string "portfolio"
    t.string "commercial_licence_no"
    t.string "commercial_licence_file"
    t.date "commercial_licence_expiry_date"
    t.string "accredited_service_provider_licence_file"
    t.string "demerit_acknowledgement_file"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["service_provider_id"], name: "index_service_provider_details_on_service_provider_id"
  end

  create_table "survey_questionnaire_versions", force: :cascade do |t|
    t.integer "version", default: 0, null: false
    t.datetime "released_at", precision: nil
    t.bigint "survey_type_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["survey_type_id"], name: "index_survey_questionnaire_versions_on_survey_type_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.string "question_text"
    t.text "description"
    t.boolean "mandatory", default: false
    t.integer "position", default: 0
    t.string "question_type"
    t.bigint "survey_questionnaire_version_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["survey_questionnaire_version_id"], name: "index_survey_questions_on_survey_questionnaire_version_id"
  end

  create_table "survey_responses", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.bigint "projects_survey_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["projects_survey_id"], name: "index_survey_responses_on_projects_survey_id"
  end

  create_table "survey_types", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.integer "task_description_id", null: false
    t.integer "application_role"
    t.integer "project_role"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "taskable_id"
    t.string "taskable_type"
    t.integer "project_id"
    t.integer "certification_path_id"
    t.index ["certification_path_id"], name: "index_tasks_on_certification_path_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "user_details", force: :cascade do |t|
    t.bigint "user_id"
    t.date "dob"
    t.string "designation"
    t.string "work_experience"
    t.string "qid_or_passport_number"
    t.string "gender"
    t.string "qid_file"
    t.string "university_credentials_file"
    t.string "work_experience_file"
    t.string "cgp_licence_file"
    t.string "qid_work_permit_file"
    t.string "gsas_energey_assessment_licence_file"
    t.string "energy_assessor_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_user_details_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "last_sign_in_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "role"
    t.string "username"
    t.boolean "gord_employee", default: false, null: false
    t.string "name"
    t.datetime "last_notified_at", precision: nil
    t.string "organization_name"
    t.string "type", default: "User"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "service_provider_id"
    t.string "name_suffix"
    t.string "gender"
    t.string "middle_name"
    t.string "last_name"
    t.date "dob"
    t.string "email_alternate"
    t.string "country"
    t.string "city"
    t.string "mobile_area_code"
    t.string "mobile"
    t.string "designation"
    t.integer "work_experience"
    t.string "organization_address"
    t.string "organization_country"
    t.string "organization_city"
    t.string "organization_website"
    t.string "organization_phone_area_code"
    t.string "organization_phone"
    t.string "organization_fax_area_code"
    t.string "organization_fax"
    t.string "gsas_id"
    t.string "qid_or_passport_number"
    t.datetime "approved_at", precision: nil
    t.boolean "active", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "access_licences", "licences"
  add_foreign_key "access_licences", "users"
  add_foreign_key "actual_project_images", "certification_paths"
  add_foreign_key "actual_project_images", "projects"
  add_foreign_key "archives", "users"
  add_foreign_key "audit_logs", "audit_log_visibilities"
  add_foreign_key "audit_logs", "projects"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "building_types", "building_type_groups"
  add_foreign_key "calculator_data", "calculators"
  add_foreign_key "certification_path_methods", "certification_paths"
  add_foreign_key "certification_path_reports", "certification_paths"
  add_foreign_key "certification_paths", "certificates"
  add_foreign_key "certification_paths", "certification_path_statuses"
  add_foreign_key "certification_paths", "projects"
  add_foreign_key "certification_paths", "scheme_mixes", column: "main_scheme_mix_id"
  add_foreign_key "development_type_schemes", "development_types"
  add_foreign_key "development_type_schemes", "schemes"
  add_foreign_key "development_types", "certificates"
  add_foreign_key "documents", "certification_path_statuses"
  add_foreign_key "documents", "certification_paths"
  add_foreign_key "documents", "users"
  add_foreign_key "field_data", "calculator_data"
  add_foreign_key "field_data", "fields"
  add_foreign_key "fields", "calculators"
  add_foreign_key "notification_types_users", "notification_types"
  add_foreign_key "notification_types_users", "projects"
  add_foreign_key "notification_types_users", "users"
  add_foreign_key "offline_certification_paths", "offline_projects"
  add_foreign_key "offline_project_documents", "offline_projects"
  add_foreign_key "offline_scheme_mix_criterion", "offline_scheme_mixes"
  add_foreign_key "offline_scheme_mixes", "offline_certification_paths"
  add_foreign_key "project_rendering_images", "certification_paths"
  add_foreign_key "project_rendering_images", "projects"
  add_foreign_key "projects", "building_type_groups"
  add_foreign_key "projects", "building_types"
  add_foreign_key "projects_surveys", "projects"
  add_foreign_key "projects_surveys", "survey_questionnaire_versions"
  add_foreign_key "projects_surveys", "survey_types"
  add_foreign_key "projects_users", "projects"
  add_foreign_key "projects_users", "users"
  add_foreign_key "question_options", "survey_questions"
  add_foreign_key "question_responses", "survey_questions"
  add_foreign_key "question_responses", "survey_responses"
  add_foreign_key "requirement_data", "requirements"
  add_foreign_key "requirement_data", "users"
  add_foreign_key "scheme_categories", "schemes"
  add_foreign_key "scheme_criteria", "scheme_categories"
  add_foreign_key "scheme_criteria_requirements", "requirements"
  add_foreign_key "scheme_criteria_requirements", "scheme_criteria"
  add_foreign_key "scheme_criterion_boxes", "scheme_criteria"
  add_foreign_key "scheme_criterion_incentives", "scheme_criteria"
  add_foreign_key "scheme_criterion_performance_labels", "scheme_criteria"
  add_foreign_key "scheme_criterion_texts", "scheme_criteria"
  add_foreign_key "scheme_mix_criteria", "scheme_criteria"
  add_foreign_key "scheme_mix_criteria", "scheme_mixes"
  add_foreign_key "scheme_mix_criteria_documents", "documents"
  add_foreign_key "scheme_mix_criteria_documents", "scheme_mix_criteria"
  add_foreign_key "scheme_mix_criteria_requirement_data", "requirement_data"
  add_foreign_key "scheme_mix_criteria_requirement_data", "scheme_mix_criteria"
  add_foreign_key "scheme_mix_criterion_boxes", "scheme_criterion_boxes"
  add_foreign_key "scheme_mix_criterion_boxes", "scheme_mix_criteria"
  add_foreign_key "scheme_mix_criterion_incentives", "scheme_criterion_incentives"
  add_foreign_key "scheme_mix_criterion_incentives", "scheme_mix_criteria"
  add_foreign_key "scheme_mix_criterion_performance_labels", "scheme_criterion_performance_labels", column: "scheme_criterion_performance_labels_id"
  add_foreign_key "scheme_mix_criterion_performance_labels", "scheme_mix_criteria"
  add_foreign_key "scheme_mixes", "certification_paths"
  add_foreign_key "scheme_mixes", "schemes"
  add_foreign_key "service_provider_details", "users", column: "service_provider_id"
  add_foreign_key "survey_questionnaire_versions", "survey_types"
  add_foreign_key "survey_questions", "survey_questionnaire_versions"
  add_foreign_key "survey_responses", "projects_surveys"
  add_foreign_key "tasks", "certification_paths"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users"
  add_foreign_key "user_details", "users"
  add_foreign_key "users", "users", column: "service_provider_id"
end
