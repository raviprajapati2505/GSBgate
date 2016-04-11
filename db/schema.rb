# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160411102445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "audit_log_visibilities", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "audit_logs", force: :cascade do |t|
    t.text     "system_message"
    t.text     "user_comment"
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "new_status"
    t.integer  "old_status"
    t.integer  "certification_path_id"
    t.integer  "audit_log_visibility_id"
  end

  add_index "audit_logs", ["audit_log_visibility_id"], name: "index_audit_logs_on_audit_log_visibility_id", using: :btree
  add_index "audit_logs", ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id", using: :btree
  add_index "audit_logs", ["project_id"], name: "index_audit_logs_on_project_id", using: :btree
  add_index "audit_logs", ["system_message"], name: "index_audit_logs_on_system_message", using: :btree
  add_index "audit_logs", ["user_comment"], name: "index_audit_logs_on_user_comment", using: :btree
  add_index "audit_logs", ["user_id"], name: "index_audit_logs_on_user_id", using: :btree

  create_table "background_executions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calculator_data", force: :cascade do |t|
    t.integer  "calculator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "calculator_data", ["calculator_id"], name: "index_calculator_data_on_calculator_id", using: :btree

  create_table "calculators", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "certificates", force: :cascade do |t|
    t.string   "name"
    t.integer  "certificate_type"
    t.integer  "assessment_stage"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "display_weight"
    t.string   "gsas_version"
    t.integer  "certification_type"
  end

  create_table "certification_path_statuses", force: :cascade do |t|
    t.string   "name"
    t.string   "past_name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "certification_paths", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "certificate_id"
    t.boolean  "pcr_track",                    default: false
    t.integer  "duration"
    t.datetime "started_at"
    t.integer  "certification_path_status_id"
    t.boolean  "appealed",                     default: false
    t.datetime "certified_at"
    t.integer  "main_scheme_mix_id"
    t.boolean  "main_scheme_mix_selected",     default: false, null: false
    t.integer  "max_review_count",             default: 2
    t.integer  "development_type_id"
  end

  add_index "certification_paths", ["certification_path_status_id"], name: "index_certification_paths_on_certification_path_status_id", using: :btree
  add_index "certification_paths", ["development_type_id"], name: "index_certification_paths_on_development_type_id", using: :btree
  add_index "certification_paths", ["main_scheme_mix_id"], name: "index_certification_paths_on_main_scheme_mix_id", using: :btree
  add_index "certification_paths", ["project_id"], name: "index_certification_paths_on_project_id", using: :btree

  create_table "development_type_schemes", force: :cascade do |t|
    t.integer  "development_type_id"
    t.integer  "scheme_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "development_type_schemes", ["development_type_id"], name: "index_development_type_schemes_on_development_type_id", using: :btree
  add_index "development_type_schemes", ["scheme_id"], name: "index_development_type_schemes_on_scheme_id", using: :btree

  create_table "development_types", force: :cascade do |t|
    t.integer  "certificate_id"
    t.string   "name"
    t.integer  "display_weight"
    t.boolean  "mixable"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "development_types", ["certificate_id"], name: "index_development_types_on_certificate_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "document_file"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "store_dir"
  end

  add_index "documents", ["user_id"], name: "by_user", using: :btree
  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree

  create_table "field_data", force: :cascade do |t|
    t.integer  "field_id"
    t.string   "string_value"
    t.integer  "integer_value"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "calculator_datum_id"
    t.string   "type"
  end

  add_index "field_data", ["field_id"], name: "index_field_data_on_field_id", using: :btree

  create_table "fields", force: :cascade do |t|
    t.integer  "calculator_id"
    t.string   "name"
    t.string   "machine_name"
    t.string   "datum_type"
    t.string   "validation"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "required"
    t.text     "help_text"
    t.string   "prefix"
    t.string   "suffix"
  end

  add_index "fields", ["calculator_id"], name: "index_fields_on_calculator_id", using: :btree

  create_table "notification_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "project_level"
  end

  create_table "notification_types_users", force: :cascade do |t|
    t.integer  "notification_type_id"
    t.integer  "user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "project_id"
  end

  add_index "notification_types_users", ["notification_type_id"], name: "index_notification_types_users_on_notification_type_id", using: :btree
  add_index "notification_types_users", ["project_id"], name: "index_notification_types_users_on_project_id", using: :btree
  add_index "notification_types_users", ["user_id"], name: "index_notification_types_users_on_user_id", using: :btree

  create_table "owners", force: :cascade do |t|
    t.string  "name",              null: false
    t.boolean "governmental"
    t.boolean "private_developer"
    t.boolean "private_owner"
  end

  create_table "projects", force: :cascade do |t|
    t.string    "name"
    t.datetime  "created_at",                                                                                   null: false
    t.datetime  "updated_at",                                                                                   null: false
    t.text      "description"
    t.text      "address"
    t.string    "location"
    t.string    "country"
    t.geography "latlng",                 limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.integer   "gross_area"
    t.integer   "certified_area"
    t.integer   "carpark_area"
    t.integer   "project_site_area"
    t.string    "code"
    t.integer   "construction_year"
    t.string    "location_plan_file"
    t.string    "site_plan_file"
    t.string    "design_brief_file"
    t.string    "project_narrative_file"
    t.string    "owner",                                                                           default: "", null: false
    t.string    "service_provider",                                                                default: "", null: false
  end

  create_table "projects_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "role"
  end

  add_index "projects_users", ["project_id"], name: "index_projects_users_on_project_id", using: :btree
  add_index "projects_users", ["user_id", "project_id", "role"], name: "index_projects_users_on_user_id_and_project_id_and_role", unique: true, using: :btree
  add_index "projects_users", ["user_id"], name: "index_projects_users_on_user_id", using: :btree

  create_table "requirement_data", force: :cascade do |t|
    t.integer  "calculator_datum_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "requirement_id"
    t.integer  "status"
    t.integer  "user_id"
    t.date     "due_date"
  end

  add_index "requirement_data", ["user_id"], name: "index_requirement_data_on_user_id", using: :btree

  create_table "requirements", force: :cascade do |t|
    t.integer  "calculator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "name"
  end

  create_table "scheme_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "code",            limit: 2
    t.text     "description"
    t.text     "impacts"
    t.text     "mitigate_impact"
    t.integer  "scheme_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "display_weight"
    t.boolean  "shared",                    default: false, null: false
  end

  add_index "scheme_categories", ["code", "scheme_id"], name: "index_scheme_categories_on_code_and_scheme_id", unique: true, using: :btree
  add_index "scheme_categories", ["code"], name: "index_scheme_categories_on_code", using: :btree
  add_index "scheme_categories", ["scheme_id"], name: "index_scheme_categories_on_scheme_id", using: :btree

  create_table "scheme_criteria", force: :cascade do |t|
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.decimal  "weight",              precision: 5, scale: 2
    t.string   "name"
    t.integer  "number"
    t.string   "scores"
    t.integer  "scheme_category_id"
    t.decimal  "incentive_weight",    precision: 5, scale: 2, default: 0.0
    t.integer  "minimum_score",                                             null: false
    t.integer  "maximum_score",                                             null: false
    t.integer  "minimum_valid_score",                                       null: false
  end

  add_index "scheme_criteria", ["number"], name: "index_scheme_criteria_on_number", using: :btree
  add_index "scheme_criteria", ["scheme_category_id", "name"], name: "index_scheme_criteria_on_scheme_category_id_and_name", unique: true, using: :btree
  add_index "scheme_criteria", ["scheme_category_id", "number"], name: "index_scheme_criteria_on_scheme_category_id_and_number", unique: true, using: :btree
  add_index "scheme_criteria", ["scheme_category_id"], name: "index_scheme_criteria_on_scheme_category_id", using: :btree

  create_table "scheme_criteria_requirements", force: :cascade do |t|
    t.integer  "scheme_criterion_id"
    t.integer  "requirement_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "scheme_criteria_requirements", ["requirement_id"], name: "index_scheme_criteria_requirements_on_requirement_id", using: :btree
  add_index "scheme_criteria_requirements", ["scheme_criterion_id"], name: "index_scheme_criteria_requirements_on_scheme_criterion_id", using: :btree

  create_table "scheme_criterion_texts", force: :cascade do |t|
    t.string   "name"
    t.text     "html_text"
    t.integer  "display_weight"
    t.boolean  "visible"
    t.integer  "scheme_criterion_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "scheme_criterion_texts", ["name", "scheme_criterion_id"], name: "index_scheme_criterion_texts_on_name_and_scheme_criterion_id", unique: true, using: :btree
  add_index "scheme_criterion_texts", ["scheme_criterion_id"], name: "index_scheme_criterion_texts_on_scheme_criterion_id", using: :btree

  create_table "scheme_mix_criteria", force: :cascade do |t|
    t.integer  "scheme_mix_id"
    t.integer  "scheme_criterion_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "status"
    t.integer  "certifier_id"
    t.date     "due_date"
    t.integer  "targeted_score"
    t.integer  "submitted_score"
    t.integer  "achieved_score"
    t.integer  "main_scheme_mix_criterion_id"
    t.boolean  "in_review",                    default: false
    t.integer  "review_count",                 default: 0
  end

  add_index "scheme_mix_criteria", ["certifier_id"], name: "index_scheme_mix_criteria_on_certifier_id", using: :btree
  add_index "scheme_mix_criteria", ["main_scheme_mix_criterion_id"], name: "index_scheme_mix_criteria_on_main_scheme_mix_criterion_id", using: :btree
  add_index "scheme_mix_criteria", ["scheme_criterion_id"], name: "index_scheme_mix_criteria_on_scheme_criterion_id", using: :btree
  add_index "scheme_mix_criteria", ["scheme_mix_id"], name: "index_scheme_mix_criteria_on_scheme_mix_id", using: :btree

  create_table "scheme_mix_criteria_documents", force: :cascade do |t|
    t.integer  "scheme_mix_criterion_id"
    t.integer  "document_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "status"
  end

  add_index "scheme_mix_criteria_documents", ["document_id"], name: "index_scheme_mix_criteria_documents_on_document_id", using: :btree
  add_index "scheme_mix_criteria_documents", ["scheme_mix_criterion_id", "document_id"], name: "scheme_mix_criteria_documents_unique", unique: true, using: :btree
  add_index "scheme_mix_criteria_documents", ["scheme_mix_criterion_id"], name: "index_scheme_mix_criteria_documents_on_scheme_mix_criterion_id", using: :btree

  create_table "scheme_mix_criteria_requirement_data", force: :cascade do |t|
    t.integer  "scheme_mix_criterion_id"
    t.integer  "requirement_datum_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "scheme_mix_criteria_requirement_data", ["requirement_datum_id"], name: "by_requirement_datum", using: :btree
  add_index "scheme_mix_criteria_requirement_data", ["scheme_mix_criterion_id"], name: "by_scheme_mix_criterion", using: :btree

  create_table "scheme_mixes", force: :cascade do |t|
    t.integer  "certification_path_id"
    t.integer  "weight"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "scheme_id"
    t.string   "custom_name"
  end

  add_index "scheme_mixes", ["certification_path_id", "scheme_id", "custom_name"], name: "ui_custom_name_scheme", unique: true, using: :btree
  add_index "scheme_mixes", ["certification_path_id"], name: "index_scheme_mixes_on_certification_path_id", using: :btree

  create_table "schemes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "gsas_version"
    t.boolean  "renovation",       default: false, null: false
    t.string   "gsas_document"
    t.integer  "certificate_type"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "task_description_id",   null: false
    t.integer  "application_role"
    t.integer  "project_role"
    t.integer  "user_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "taskable_id"
    t.string   "taskable_type"
    t.integer  "project_id"
    t.integer  "certification_path_id"
  end

  add_index "tasks", ["certification_path_id"], name: "index_tasks_on_certification_path_id", using: :btree
  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id", using: :btree
  add_index "tasks", ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id", using: :btree
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "",    null: false
    t.string   "encrypted_password",  default: ""
    t.integer  "sign_in_count",       default: 0,     null: false
    t.datetime "last_sign_in_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role"
    t.string   "linkme_member_id"
    t.string   "username",                            null: false
    t.boolean  "linkme_user",         default: true,  null: false
    t.boolean  "gord_employee",       default: false, null: false
    t.boolean  "cgp_license",         default: false, null: false
    t.text     "picture"
    t.string   "name"
    t.boolean  "cgp_license_expired", default: false, null: false
    t.datetime "last_notified_at"
  end

  add_index "users", ["linkme_member_id"], name: "index_users_on_linkme_member_id", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "audit_logs", "audit_log_visibilities"
  add_foreign_key "audit_logs", "projects"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "calculator_data", "calculators"
  add_foreign_key "certification_paths", "certificates"
  add_foreign_key "certification_paths", "certification_path_statuses"
  add_foreign_key "certification_paths", "projects"
  add_foreign_key "certification_paths", "scheme_mixes", column: "main_scheme_mix_id"
  add_foreign_key "development_type_schemes", "development_types"
  add_foreign_key "development_type_schemes", "schemes"
  add_foreign_key "development_types", "certificates"
  add_foreign_key "documents", "users"
  add_foreign_key "field_data", "calculator_data"
  add_foreign_key "field_data", "fields"
  add_foreign_key "fields", "calculators"
  add_foreign_key "notification_types_users", "notification_types"
  add_foreign_key "notification_types_users", "projects"
  add_foreign_key "notification_types_users", "users"
  add_foreign_key "projects_users", "projects"
  add_foreign_key "projects_users", "users"
  add_foreign_key "requirement_data", "requirements"
  add_foreign_key "requirement_data", "users"
  add_foreign_key "scheme_categories", "schemes"
  add_foreign_key "scheme_criteria", "scheme_categories"
  add_foreign_key "scheme_criteria_requirements", "requirements"
  add_foreign_key "scheme_criteria_requirements", "scheme_criteria"
  add_foreign_key "scheme_criterion_texts", "scheme_criteria"
  add_foreign_key "scheme_mix_criteria", "scheme_criteria"
  add_foreign_key "scheme_mix_criteria", "scheme_mixes"
  add_foreign_key "scheme_mix_criteria_documents", "documents"
  add_foreign_key "scheme_mix_criteria_documents", "scheme_mix_criteria"
  add_foreign_key "scheme_mix_criteria_requirement_data", "requirement_data"
  add_foreign_key "scheme_mix_criteria_requirement_data", "scheme_mix_criteria"
  add_foreign_key "scheme_mixes", "certification_paths"
  add_foreign_key "scheme_mixes", "schemes"
  add_foreign_key "tasks", "certification_paths"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users"
end
