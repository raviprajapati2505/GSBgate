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

ActiveRecord::Schema.define(version: 20150520070550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

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

  create_table "certification_path_statuses", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "certification_paths", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "certificate_id"
  end

  add_index "certification_paths", ["project_id"], name: "index_certification_paths_on_project_id", using: :btree

  create_table "criteria", force: :cascade do |t|
    t.string   "code",        limit: 5
    t.string   "name"
    t.integer  "score_min",   limit: 2
    t.integer  "score_max",   limit: 2
    t.integer  "category_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "criteria", ["category_id"], name: "index_criteria_on_category_id", using: :btree
  add_index "criteria", ["code"], name: "index_criteria_on_code", unique: true, using: :btree

  create_table "project_authorizations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "permission"
    t.integer  "category_id"
  end

  add_index "project_authorizations", ["category_id"], name: "index_project_authorizations_on_category_id", using: :btree
  add_index "project_authorizations", ["project_id"], name: "index_project_authorizations_on_project_id", using: :btree
  add_index "project_authorizations", ["user_id"], name: "index_project_authorizations_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string    "name"
    t.integer   "user_id"
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
  end

  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

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

  add_foreign_key "certification_paths", "projects"
  add_foreign_key "criteria", "categories"
  add_foreign_key "project_authorizations", "categories"
  add_foreign_key "project_authorizations", "projects"
  add_foreign_key "project_authorizations", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "scheme_mixes", "certification_paths"
  add_foreign_key "scheme_mixes", "schemes"
  add_foreign_key "schemes", "certificates"
end
