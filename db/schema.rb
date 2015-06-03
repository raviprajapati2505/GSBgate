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

ActiveRecord::Schema.define(version: 20150603112625) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "calculator_data", force: :cascade do |t|
    t.integer  "calculator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "calculator_data", ["calculator_id"], name: "index_calculator_data_on_calculator_id", using: :btree

  create_table "calculators", force: :cascade do |t|
    t.string   "class_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "code",       limit: 2
    t.string   "name"
    t.integer  "weight"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "categories", ["code"], name: "index_categories_on_code", unique: true, using: :btree

  create_table "certificates", force: :cascade do |t|
    t.string   "label"
    t.integer  "certificate_type"
    t.integer  "assessment_stage"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "certification_paths", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "certificate_id"
    t.integer  "status"
  end

  add_index "certification_paths", ["project_id"], name: "index_certification_paths_on_project_id", using: :btree

  create_table "criteria", force: :cascade do |t|
    t.string   "code",        limit: 5
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "criteria", ["category_id"], name: "index_criteria_on_category_id", using: :btree
  add_index "criteria", ["code"], name: "index_criteria_on_code", unique: true, using: :btree

  create_table "document_data", force: :cascade do |t|
    t.integer  "document_id"
    t.string   "file_path"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "document_data", ["document_id"], name: "index_document_data_on_document_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_data", force: :cascade do |t|
    t.integer  "field_id"
    t.string   "string_value"
    t.integer  "integer_value"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "calculator_datum_id"
  end

  add_index "field_data", ["field_id"], name: "index_field_data_on_field_id", using: :btree

  create_table "fields", force: :cascade do |t|
    t.integer  "calculator_id"
    t.string   "label"
    t.string   "name"
    t.string   "type"
    t.string   "validation"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "required"
    t.text     "help_text"
    t.string   "prefix"
    t.string   "suffix"
  end

  add_index "fields", ["calculator_id"], name: "index_fields_on_calculator_id", using: :btree

  create_table "project_authorizations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "permission"
    t.integer  "requirement_datum_id"
  end

  add_index "project_authorizations", ["project_id"], name: "index_project_authorizations_on_project_id", using: :btree
  add_index "project_authorizations", ["requirement_datum_id"], name: "index_project_authorizations_on_requirement_datum_id", using: :btree
  add_index "project_authorizations", ["user_id"], name: "index_project_authorizations_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string    "name"
    t.datetime  "created_at",                                                                 null: false
    t.datetime  "updated_at",                                                                 null: false
    t.text      "description"
    t.text      "address"
    t.string    "location"
    t.string    "country"
    t.geography "latlng",            limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.integer   "gross_area"
    t.integer   "certified_area"
    t.integer   "carpark_area"
    t.integer   "project_site_area"
    t.integer   "client_id"
    t.integer   "owner_id"
    t.integer   "certifier_id"
  end

  create_table "requirement_data", force: :cascade do |t|
    t.integer  "reportable_data_id"
    t.string   "reportable_data_type"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "requirement_id"
  end

  create_table "requirements", force: :cascade do |t|
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "scheme_criteria", force: :cascade do |t|
    t.integer  "scheme_id"
    t.integer  "criterion_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.decimal  "weight",       precision: 4, scale: 2
  end

  add_index "scheme_criteria", ["criterion_id"], name: "index_scheme_criteria_on_criterion_id", using: :btree
  add_index "scheme_criteria", ["scheme_id"], name: "index_scheme_criteria_on_scheme_id", using: :btree

  create_table "scheme_criterion_requirements", force: :cascade do |t|
    t.integer  "scheme_criterion_id"
    t.integer  "requirement_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "scheme_criterion_requirements", ["requirement_id"], name: "index_scheme_criterion_requirements_on_requirement_id", using: :btree
  add_index "scheme_criterion_requirements", ["scheme_criterion_id"], name: "index_scheme_criterion_requirements_on_scheme_criterion_id", using: :btree

  create_table "scheme_mix_criteria", force: :cascade do |t|
    t.integer  "targeted_score"
    t.integer  "scheme_mix_id"
    t.integer  "scheme_criterion_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "submitted_score"
  end

  add_index "scheme_mix_criteria", ["scheme_criterion_id"], name: "index_scheme_mix_criteria_on_scheme_criterion_id", using: :btree
  add_index "scheme_mix_criteria", ["scheme_mix_id"], name: "index_scheme_mix_criteria_on_scheme_mix_id", using: :btree

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
  end

  add_index "scheme_mixes", ["certification_path_id"], name: "index_scheme_mixes_on_certification_path_id", using: :btree

  create_table "schemes", force: :cascade do |t|
    t.string   "label"
    t.integer  "certificate_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "version"
  end

  add_index "schemes", ["certificate_id"], name: "index_schemes_on_certificate_id", using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer  "score"
    t.text     "description"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "scheme_criterion_id"
  end

  add_index "scores", ["scheme_criterion_id"], name: "index_scores_on_scheme_criterion_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "calculator_data", "calculators"
  add_foreign_key "certification_paths", "certificates"
  add_foreign_key "certification_paths", "projects"
  add_foreign_key "criteria", "categories"
  add_foreign_key "document_data", "documents"
  add_foreign_key "field_data", "calculator_data"
  add_foreign_key "field_data", "fields"
  add_foreign_key "fields", "calculators"
  add_foreign_key "project_authorizations", "projects"
  add_foreign_key "project_authorizations", "requirement_data"
  add_foreign_key "project_authorizations", "users"
  add_foreign_key "projects", "users", column: "certifier_id"
  add_foreign_key "projects", "users", column: "client_id"
  add_foreign_key "projects", "users", column: "owner_id"
  add_foreign_key "requirement_data", "requirements"
  add_foreign_key "scheme_criteria", "criteria"
  add_foreign_key "scheme_criteria", "schemes"
  add_foreign_key "scheme_criterion_requirements", "requirements"
  add_foreign_key "scheme_criterion_requirements", "scheme_criteria"
  add_foreign_key "scheme_mix_criteria", "scheme_criteria"
  add_foreign_key "scheme_mix_criteria", "scheme_mixes"
  add_foreign_key "scheme_mix_criteria_requirement_data", "requirement_data"
  add_foreign_key "scheme_mix_criteria_requirement_data", "scheme_mix_criteria"
  add_foreign_key "scheme_mixes", "certification_paths"
  add_foreign_key "scheme_mixes", "schemes"
  add_foreign_key "schemes", "certificates"
  add_foreign_key "scores", "scheme_criteria"
end
