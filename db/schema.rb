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

ActiveRecord::Schema.define(version: 2023_06_06_114347) do

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
    t.boolean "moneter", default: false
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

  create_table "addendums", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ref_number"
    t.uuid "contract_id"
    t.json "contract_changes"
    t.date "date"
    t.text "description"
    t.index ["contract_id"], name: "index_addendums_on_contract_id"
  end

  create_table "approval_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "roles", default: [], array: true
    t.decimal "bottom_treshold_cents", default: "0.0", null: false
    t.string "bottom_treshold_currency", default: "IDR", null: false
    t.decimal "upper_treshold_cents", default: "0.0", null: false
    t.string "upper_treshold_currency", default: "IDR", null: false
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
    t.integer "number_of_notification_sent", default: 0
    t.index ["approvable_type", "approvable_id"], name: "index_approvals_on_approvable"
    t.index ["order"], name: "index_approvals_on_order"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "audit_adjustment_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "group"
    t.decimal "price_idr_cents", default: "0.0", null: false
    t.string "price_idr_currency", default: "IDR", null: false
    t.decimal "price_usd_cents", default: "0.0", null: false
    t.string "price_usd_currency", default: "USD", null: false
    t.uuid "audit_adjustment_id"
    t.string "description"
    t.decimal "rate_cents", default: "0.0", null: false
    t.string "rate_currency", default: "IDR", null: false
    t.uuid "account_id"
    t.index ["account_id"], name: "index_audit_adjustment_lines_on_account_id"
    t.index ["audit_adjustment_id"], name: "index_audit_adjustment_lines_on_audit_adjustment_id"
  end

  create_table "audit_adjustments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date"
    t.string "period"
    t.string "status"
    t.string "number_evidence"
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

  create_table "banks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "code"
  end

  create_table "bas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "contract_id"
    t.text "description"
    t.string "reference_number"
    t.date "date"
    t.date "levered_at"
    t.date "realized_at"
    t.integer "_number_of_days_late"
    t.string "status"
    t.decimal "price_cents", default: "0.0", null: false
    t.string "price_currency", default: "IDR", null: false
    t.uuid "accrued_credit_id"
    t.index ["accrued_credit_id"], name: "index_bas_on_accrued_credit_id"
    t.index ["contract_id"], name: "index_bas_on_contract_id"
  end

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "email"
    t.string "phone_number"
    t.text "address"
    t.string "npwp"
    t.string "account_bank"
    t.string "account_number"
    t.string "account_name"
    t.string "group"
    t.string "pkp_group"
    t.uuid "bank_id"
    t.uuid "company_id"
    t.index ["bank_id"], name: "index_clients_on_bank_id"
    t.index ["company_id"], name: "index_clients_on_company_id"
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

  create_table "contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "started_at"
    t.date "ended_at"
    t.string "ref_number"
    t.decimal "price_cents", default: "0.0", null: false
    t.string "price_currency", default: "IDR", null: false
    t.string "status"
    t.uuid "client_id"
    t.uuid "bank_id"
    t.string "account_number"
    t.string "account_holder"
    t.string "description"
    t.string "started_with_group"
    t.string "started_with_ref_number"
    t.date "started_with_date"
    t.integer "time_period"
    t.integer "payment_time_period"
    t.string "payment_time_period_group"
    t.uuid "accrued_debit_id"
    t.string "location"
    t.boolean "is_master_business_units_enabled", default: false
    t.uuid "master_business_unit_id"
    t.uuid "master_business_unit_location_id"
    t.uuid "master_business_unit_area_id"
    t.uuid "master_business_unit_activity_id"
    t.index ["accrued_debit_id"], name: "index_contracts_on_accrued_debit_id"
    t.index ["bank_id"], name: "index_contracts_on_bank_id"
    t.index ["client_id"], name: "index_contracts_on_client_id"
    t.index ["master_business_unit_activity_id"], name: "contract_mbuact"
    t.index ["master_business_unit_area_id"], name: "contract_mbuare"
    t.index ["master_business_unit_id"], name: "contract_mbu"
    t.index ["master_business_unit_location_id"], name: "contract_mbul"
    t.index ["status"], name: "index_contracts_on_status"
  end

  create_table "faktur_pajak_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "faktur_pajak_id"
    t.string "nama"
    t.integer "jumlah_barang"
    t.decimal "harga_satuan_cents", default: "0.0", null: false
    t.string "harga_satuan_currency", default: "IDR", null: false
    t.decimal "diskon_cents", default: "0.0", null: false
    t.string "diskon_currency", default: "IDR", null: false
    t.decimal "dpp_cents", default: "0.0", null: false
    t.string "dpp_currency", default: "IDR", null: false
    t.decimal "ppn_cents", default: "0.0", null: false
    t.string "ppn_currency", default: "IDR", null: false
    t.decimal "ppnbm_cents", default: "0.0", null: false
    t.string "ppnbm_currency", default: "IDR", null: false
    t.decimal "harga_total_cents", default: "0.0", null: false
    t.string "harga_total_currency", default: "IDR", null: false
    t.decimal "tarif_ppnbm"
    t.index ["faktur_pajak_id"], name: "index_faktur_pajak_lines_on_faktur_pajak_id"
  end

  create_table "faktur_pajaks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "kd_jenis_transaksi"
    t.string "fg_pengganti"
    t.string "nomor_faktur"
    t.date "tanggal_faktur"
    t.string "npwp_penjual"
    t.string "nama_penjual"
    t.string "alamat_penjual"
    t.decimal "jumlah_dpp_cents", default: "0.0", null: false
    t.string "jumlah_dpp_currency", default: "IDR", null: false
    t.decimal "jumlah_ppn_cents", default: "0.0", null: false
    t.string "jumlah_ppn_currency", default: "IDR", null: false
    t.decimal "jumlah_ppn_bm_cents", default: "0.0", null: false
    t.string "jumlah_ppn_bm_currency", default: "IDR", null: false
    t.string "npwp_lawan_transaksi"
    t.string "nama_lawan_transaksi"
    t.string "alamat_lawan_transaksi"
    t.string "status_approval"
    t.string "status_faktur"
    t.string "referensi"
    t.string "faktur_link"
    t.json "raw_result_from_link", default: {}
    t.string "faktur_pajakable_type"
    t.uuid "faktur_pajakable_id"
    t.index ["faktur_pajakable_type", "faktur_pajakable_id"], name: "index_faktur_pajaks_on_faktur_pajakable"
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
    t.decimal "rate_cents", default: "0.0", null: false
    t.string "rate_currency", default: "IDR", null: false
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
    t.string "location"
    t.string "source"
    t.string "transactionable_type"
    t.uuid "transactionable_id"
    t.string "origin_id"
    t.index ["company_id"], name: "index_general_transactions_on_company_id"
    t.index ["transactionable_type", "transactionable_id"], name: "index_general_transactions_on_transactionable"
  end

  create_table "invoice_direct_externals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ref_number"
    t.date "date"
    t.string "receipt_number"
    t.decimal "price_cents", default: "0.0", null: false
    t.string "price_currency", default: "IDR", null: false
    t.string "ppn_group"
    t.string "status"
    t.boolean "faktur_pajak_checked", default: false
    t.date "tax_receipt_date"
    t.string "tax_receipt_number"
    t.string "ppn_cost_group"
    t.decimal "ppn_percentage"
    t.uuid "client_id"
    t.uuid "bank_id"
    t.string "account_number"
    t.string "account_holder"
    t.string "description"
    t.string "location"
    t.uuid "bank_account_id"
    t.uuid "cost_center_id"
    t.boolean "is_master_business_units_enabled", default: false
    t.uuid "master_business_unit_id"
    t.uuid "master_business_unit_location_id"
    t.uuid "master_business_unit_area_id"
    t.uuid "master_business_unit_activity_id"
    t.index ["bank_account_id"], name: "index_invoice_direct_externals_on_bank_account_id"
    t.index ["bank_id"], name: "index_invoice_direct_externals_on_bank_id"
    t.index ["client_id"], name: "index_invoice_direct_externals_on_client_id"
    t.index ["cost_center_id"], name: "index_invoice_direct_externals_on_cost_center_id"
    t.index ["master_business_unit_activity_id"], name: "ide_mbuact"
    t.index ["master_business_unit_area_id"], name: "ide_mbuare"
    t.index ["master_business_unit_id"], name: "ide_mbu"
    t.index ["master_business_unit_location_id"], name: "ide_mbul"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "spp_number"
    t.string "ref_number"
    t.date "date"
    t.string "receipt_number"
    t.decimal "price_cents", default: "0.0", null: false
    t.string "price_currency", default: "IDR", null: false
    t.string "ppn_group"
    t.date "tax_receipt_date"
    t.string "tax_receipt_number"
    t.string "invoiceable_type"
    t.uuid "invoiceable_id"
    t.string "status"
    t.string "ppn_cost_group"
    t.decimal "pph_percentage"
    t.decimal "fine_cents", default: "0.0", null: false
    t.string "fine_currency", default: "IDR", null: false
    t.date "debt_age_started_at"
    t.decimal "ppn_percentage"
    t.boolean "spp_checked", default: false
    t.boolean "invoice_checked", default: false
    t.boolean "kwitansi_checked", default: false
    t.boolean "faktur_pajak_checked", default: false
    t.datetime "received_at"
    t.uuid "pph_id"
    t.uuid "accrued_credit_id"
    t.uuid "bank_account_id"
    t.uuid "fine_account_id"
    t.decimal "bonus_cents", default: "0.0", null: false
    t.string "bonus_currency", default: "IDR", null: false
    t.uuid "bonus_account_id"
    t.boolean "bamp_checked", default: false
    t.boolean "bapb_checked", default: false
    t.boolean "bastp_checked", default: false
    t.boolean "copy_perjanjian_checked", default: false
    t.boolean "copy_spmk_checked", default: false
    t.boolean "copy_npwp_pkp_checked", default: false
    t.boolean "jaminan_pemeliharaan_checked", default: false
    t.index ["accrued_credit_id"], name: "index_invoices_on_accrued_credit_id"
    t.index ["bank_account_id"], name: "index_invoices_on_bank_account_id"
    t.index ["bonus_account_id"], name: "index_invoices_on_bonus_account_id"
    t.index ["fine_account_id"], name: "index_invoices_on_fine_account_id"
    t.index ["invoiceable_type", "invoiceable_id"], name: "index_invoices_on_invoiceable"
    t.index ["pph_id"], name: "index_invoices_on_pph_id"
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
    t.string "location"
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

  create_table "report_references", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "report_id"
    t.string "account_code"
    t.string "account_name"
    t.string "reference_code"
    t.index ["report_id"], name: "index_report_references_on_report_id"
  end

  create_table "reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.boolean "shown"
    t.uuid "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "group"
    t.string "display", default: "html"
    t.index ["company_id"], name: "index_reports_on_company_id"
  end

  create_table "reval_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "group"
    t.decimal "price_idr_cents", default: "0.0", null: false
    t.string "price_idr_currency", default: "IDR", null: false
    t.decimal "price_usd_cents", default: "0.0", null: false
    t.string "price_usd_currency", default: "USD", null: false
    t.uuid "reval_id"
    t.string "description"
    t.uuid "account_id"
    t.index ["account_id"], name: "index_reval_lines_on_account_id"
    t.index ["reval_id"], name: "index_reval_lines_on_reval_id"
  end

  create_table "revals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date"
    t.string "period"
    t.string "status"
    t.string "number_evidence"
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

  create_table "saved_report_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "month"
    t.integer "year"
    t.date "date"
    t.uuid "report_line_id"
    t.decimal "price_idr_cents", default: "0.0", null: false
    t.string "price_idr_currency", default: "IDR", null: false
    t.decimal "price_usd_cents", default: "0.0", null: false
    t.string "price_usd_currency", default: "USD", null: false
    t.index ["report_line_id"], name: "index_saved_report_lines_on_report_line_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.uuid "company_id"
    t.string "name"
    t.string "phone_number"
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
  add_foreign_key "addendums", "contracts"
  add_foreign_key "approvals", "users"
  add_foreign_key "audit_adjustment_lines", "accounts"
  add_foreign_key "audit_adjustment_lines", "audit_adjustments"
  add_foreign_key "bas", "accounts", column: "accrued_credit_id"
  add_foreign_key "bas", "contracts"
  add_foreign_key "clients", "banks"
  add_foreign_key "clients", "companies"
  add_foreign_key "contracts", "accounts", column: "accrued_debit_id"
  add_foreign_key "contracts", "banks"
  add_foreign_key "contracts", "clients"
  add_foreign_key "contracts", "master_business_units"
  add_foreign_key "contracts", "master_business_units", column: "master_business_unit_activity_id"
  add_foreign_key "contracts", "master_business_units", column: "master_business_unit_area_id"
  add_foreign_key "contracts", "master_business_units", column: "master_business_unit_location_id"
  add_foreign_key "faktur_pajak_lines", "faktur_pajaks"
  add_foreign_key "general_transaction_lines", "general_transactions"
  add_foreign_key "general_transaction_lines", "master_business_units"
  add_foreign_key "general_transaction_lines", "master_business_units", column: "master_business_unit_activity_id"
  add_foreign_key "general_transaction_lines", "master_business_units", column: "master_business_unit_area_id"
  add_foreign_key "general_transaction_lines", "master_business_units", column: "master_business_unit_location_id"
  add_foreign_key "general_transactions", "companies"
  add_foreign_key "invoice_direct_externals", "accounts", column: "bank_account_id"
  add_foreign_key "invoice_direct_externals", "accounts", column: "cost_center_id"
  add_foreign_key "invoice_direct_externals", "banks"
  add_foreign_key "invoice_direct_externals", "clients"
  add_foreign_key "invoice_direct_externals", "master_business_units"
  add_foreign_key "invoice_direct_externals", "master_business_units", column: "master_business_unit_activity_id"
  add_foreign_key "invoice_direct_externals", "master_business_units", column: "master_business_unit_area_id"
  add_foreign_key "invoice_direct_externals", "master_business_units", column: "master_business_unit_location_id"
  add_foreign_key "invoices", "accounts", column: "accrued_credit_id"
  add_foreign_key "invoices", "accounts", column: "bank_account_id"
  add_foreign_key "invoices", "accounts", column: "bonus_account_id"
  add_foreign_key "invoices", "accounts", column: "fine_account_id"
  add_foreign_key "invoices", "accounts", column: "pph_id"
  add_foreign_key "journals", "companies"
  add_foreign_key "report_lines", "reports"
  add_foreign_key "report_references", "reports"
  add_foreign_key "reports", "companies"
  add_foreign_key "reval_lines", "accounts"
  add_foreign_key "reval_lines", "revals"
  add_foreign_key "saved_report_lines", "report_lines"
  add_foreign_key "users", "companies"
end
