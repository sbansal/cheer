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

ActiveRecord::Schema.define(version: 2021_12_26_033435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "account_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "asset_category"
    t.jsonb "subtype_array"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "balances", force: :cascade do |t|
    t.float "available"
    t.float "current"
    t.float "limit"
    t.string "currency_code"
    t.integer "bank_account_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "plaid_account_id"
    t.string "name"
    t.string "official_name"
    t.string "account_type"
    t.string "account_subtype"
    t.string "mask"
    t.float "balance_available"
    t.float "balance_limit"
    t.string "balance_currency_code"
    t.integer "login_item_id"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "institution_id"
    t.string "classification"
    t.float "current_balance"
    t.datetime "current_balance_updated_at"
    t.text "address_line_1"
    t.text "address_line_2"
  end

  create_table "categories", force: :cascade do |t|
    t.string "group"
    t.jsonb "hierarchy"
    t.string "plaid_category_id"
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "descriptive_name"
    t.boolean "essential"
    t.string "name"
    t.text "hierarchy_string"
    t.index ["plaid_category_id"], name: "index_categories_on_plaid_category_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "summary"
    t.string "global_id"
    t.jsonb "metadata"
    t.integer "user_id"
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "institutions", force: :cascade do |t|
    t.string "plaid_institution_id"
    t.string "name"
    t.string "url"
    t.string "logo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "login_items", force: :cascade do |t|
    t.string "plaid_item_id"
    t.string "plaid_access_token"
    t.integer "institution_id"
    t.datetime "consent_expires_at"
    t.jsonb "error_json"
    t.datetime "last_successful_transaction_update_at"
    t.datetime "last_failed_transaction_update_at"
    t.datetime "last_webhook_sent_at"
    t.string "last_webhook_code_sent"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "expired", default: false
    t.datetime "expired_at"
    t.string "link_token"
    t.datetime "link_token_expires_at"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stats", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "account_id"
    t.float "current_value"
    t.jsonb "last_change_data"
    t.jsonb "historical_trend_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "value_over_time_data", default: {}
    t.index ["account_id", "name"], name: "index_stats_on_account_id_and_name", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "last_transaction_id"
    t.integer "user_id"
    t.string "frequency"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "bank_account_id"
    t.string "description"
    t.float "amount"
    t.boolean "active", default: false
    t.index ["bank_account_id", "frequency", "description", "amount"], name: "unique_subscriptions_by_frequency", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "plaid_transaction_id"
    t.float "amount"
    t.string "currency_code"
    t.date "occured_at"
    t.date "authorized_at"
    t.jsonb "location_json"
    t.text "description"
    t.string "transaction_type"
    t.jsonb "payment_meta_json"
    t.string "payment_channel"
    t.boolean "pending", default: false
    t.string "plaid_pending_transaction_id"
    t.string "transaction_code"
    t.integer "user_id"
    t.integer "bank_account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "category_id"
    t.text "custom_description"
    t.string "merchant_name"
    t.boolean "essential"
    t.index ["custom_description"], name: "index_transactions_on_custom_description"
    t.index ["description"], name: "trgm_description_indx", opclass: :gist_trgm_ops, using: :gist
    t.index ["plaid_transaction_id"], name: "index_transactions_on_plaid_transaction_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "full_name"
    t.boolean "admin"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "account_id"
    t.boolean "account_owner"
    t.integer "sign_in_count", default: 1, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.text "otp_secret_ciphertext"
    t.integer "last_otp_at"
    t.string "time_zone", default: "UTC"
    t.boolean "weekly_summary", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
