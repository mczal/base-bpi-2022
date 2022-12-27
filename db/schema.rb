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

ActiveRecord::Schema.define(version: 2022_12_27_024214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_beginning_balances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.decimal "price_idr_cents", default: "0.0", null: false
    t.string "price_idr_currency", default: "IDR", null: false
    t.decimal "price_usd_cents", default: "0.0", null: false
    t.string "price_usd_currency", default: "USD", null: false
    t.integer "year"
  end

  create_table "account_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.string "description"
    t.integer "bottom_treshold"
    t.integer "upper_treshold"
  end

  create_table "account_master_business_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "account_id"
    t.uuid "master_business_unit_id"
    t.index ["account_id"], name: "index_account_master_business_units_on_account_id"
    t.index ["master_business_unit_id"], name: "index_account_master_business_units_on_master_business_unit_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.uuid "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "balance_type"
    t.uuid "account_category_id"
    t.boolean "isak_16", default: false
    t.boolean "non_isak", default: false
    t.boolean "fiskal", default: false
    t.index ["account_category_id"], name: "index_accounts_on_account_category_id"
    t.index ["code"], name: "index_accounts_on_code"
    t.index ["company_id"], name: "index_accounts_on_company_id"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "approvals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status"
    t.uuid "user_id"
    t.string "role"
    t.integer "order"
    t.string "name"
    t.string "approvable_type", null: false
    t.uuid "approvable_id", null: false
    t.index ["approvable_type", "approvable_id"], name: "index_approvals_on_approvable"
    t.index ["order"], name: "index_approvals_on_order"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "audits", force: :cascade do |t|
    t.uuid "auditable_id"
    t.string "auditable_type"
    t.uuid "associated_id"
    t.string "associated_type"
    t.uuid "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "closed_journals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "codename"
    t.string "slug"
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "general_transaction_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.uuid "general_transaction_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "price_idr_cents", default: "0.0", null: false
    t.string "price_idr_currency", default: "IDR", null: false
    t.decimal "price_usd_cents", default: "0.0", null: false
    t.string "price_usd_currency", default: "USD", null: false
    t.string "group"
    t.boolean "is_master_business_units_enabled", default: false
    t.uuid "master_business_unit_id"
    t.uuid "master_business_unit_location_id"
    t.uuid "master_business_unit_area_id"
    t.uuid "master_business_unit_activity_id"
    t.index ["general_transaction_id"], name: "index_general_transaction_lines_on_general_transaction_id"
    t.index ["master_business_unit_activity_id"], name: "gtl_mbuact"
    t.index ["master_business_unit_area_id"], name: "gtl_mbuare"
    t.index ["master_business_unit_id"], name: "gtl_mbu"
    t.index ["master_business_unit_location_id"], name: "gtl_mbul"
  end

  create_table "general_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "number_evidence"
    t.date "date"
    t.uuid "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "rates_source"
    t.string "rates_group"
    t.string "input_option"
    t.json "end_of_period_rates_options", default: {}
    t.json "fixed_rates_options", default: {}
    t.string "status"
    t.index ["company_id"], name: "index_general_transactions_on_company_id"
  end

  create_table "journals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date"
    t.string "code"
    t.string "description"
    t.decimal "debit_idr_cents", default: "0.0", null: false
    t.string "debit_idr_currency", default: "IDR", null: false
    t.decimal "credit_idr_cents", default: "0.0", null: false
    t.string "credit_idr_currency", default: "IDR", null: false
    t.string "journalable_type", null: false
    t.uuid "journalable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "company_id"
    t.string "number_evidence"
    t.decimal "debit_usd_cents", default: "0.0", null: false
    t.string "debit_usd_currency", default: "USD", null: false
    t.decimal "credit_usd_cents", default: "0.0", null: false
    t.string "credit_usd_currency", default: "USD", null: false
    t.json "rates_options", default: {}
    t.index ["company_id"], name: "index_journals_on_company_id"
    t.index ["journalable_type", "journalable_id"], name: "index_journals_on_journalable"
  end

  create_table "master_business_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.text "description"
    t.string "group"
  end

  create_table "rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "buying_cents", default: "0.0", null: false
    t.string "buying_currency", default: "IDR", null: false
    t.decimal "selling_cents", default: "0.0", null: false
    t.string "selling_currency", default: "IDR", null: false
    t.string "origin"
    t.date "published_date"
  end

  create_table "report_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.string "codes", default: [], array: true
    t.string "formula"
    t.string "group"
    t.uuid "report_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["report_id"], name: "index_report_lines_on_report_id"
  end

  create_table "reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.boolean "shown"
    t.uuid "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_reports_on_company_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.uuid "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.uuid "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "account_master_business_units", "accounts"
  add_foreign_key "account_master_business_units", "master_business_units"
  add_foreign_key "accounts", "account_categories"
  add_foreign_key "accounts", "companies"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "approvals", "users"
  add_foreign_key "general_transaction_lines", "general_transactions"
  add_foreign_key "general_transaction_lines", "master_business_units"
  add_foreign_key "general_transaction_lines", "master_business_units", column: "master_business_unit_activity_id"
  add_foreign_key "general_transaction_lines", "master_business_units", column: "master_business_unit_area_id"
  add_foreign_key "general_transaction_lines", "master_business_units", column: "master_business_unit_location_id"
  add_foreign_key "general_transactions", "companies"
  add_foreign_key "journals", "companies"
  add_foreign_key "report_lines", "reports"
  add_foreign_key "reports", "companies"
  add_foreign_key "users", "companies"
end
