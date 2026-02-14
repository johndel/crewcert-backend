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

ActiveRecord::Schema[8.1].define(version: 2026_02_14_175601) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "certificate_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "crew_member_id", null: false
    t.datetime "expires_at"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.datetime "submitted_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["crew_member_id"], name: "index_certificate_requests_on_crew_member_id"
    t.index ["expires_at"], name: "index_certificate_requests_on_expires_at"
    t.index ["status"], name: "index_certificate_requests_on_status"
    t.index ["token"], name: "index_certificate_requests_on_token", unique: true
  end

  create_table "certificate_types", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "validity_period_months"
    t.index ["code"], name: "index_certificate_types_on_code", unique: true
  end

  create_table "certificates", force: :cascade do |t|
    t.string "certificate_number"
    t.bigint "certificate_type_id", null: false
    t.datetime "created_at", null: false
    t.bigint "crew_member_id", null: false
    t.date "expiry_date"
    t.jsonb "extracted_data", default: {}
    t.date "issue_date"
    t.text "rejection_reason"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.bigint "verified_by_id"
    t.index ["certificate_type_id"], name: "index_certificates_on_certificate_type_id"
    t.index ["created_at"], name: "index_certificates_on_created_at"
    t.index ["crew_member_id", "certificate_type_id"], name: "index_certificates_on_crew_member_id_and_certificate_type_id"
    t.index ["crew_member_id"], name: "index_certificates_on_crew_member_id"
    t.index ["expiry_date"], name: "index_certificates_on_expiry_date"
    t.index ["status", "expiry_date"], name: "index_certificates_on_status_and_expiry"
    t.index ["status"], name: "index_certificates_on_status"
    t.index ["verified_at"], name: "index_certificates_on_verified_at"
    t.index ["verified_by_id"], name: "index_certificates_on_verified_by_id"
  end

  create_table "crew_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vessel_id", null: false
    t.index "lower((email)::text)", name: "index_crew_members_on_lower_email", unique: true
    t.index ["email"], name: "index_crew_members_on_email"
    t.index ["role_id"], name: "index_crew_members_on_role_id"
    t.index ["vessel_id", "role_id"], name: "index_crew_members_on_vessel_id_and_role_id"
    t.index ["vessel_id"], name: "index_crew_members_on_vessel_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "matrix_requirements", force: :cascade do |t|
    t.bigint "certificate_type_id", null: false
    t.datetime "created_at", null: false
    t.string "requirement_level", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vessel_id", null: false
    t.index ["certificate_type_id"], name: "index_matrix_requirements_on_certificate_type_id"
    t.index ["role_id"], name: "index_matrix_requirements_on_role_id"
    t.index ["vessel_id", "role_id", "certificate_type_id"], name: "idx_matrix_requirements_unique", unique: true
    t.index ["vessel_id", "role_id", "certificate_type_id"], name: "index_matrix_requirements_composite", unique: true
    t.index ["vessel_id", "role_id"], name: "index_matrix_requirements_vessel_role"
    t.index ["vessel_id"], name: "index_matrix_requirements_on_vessel_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["position"], name: "index_roles_on_position"
  end

  create_table "super_admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_super_admins_on_email", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vessels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "imo"
    t.string "management_company"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_vessels_on_lower_name"
    t.index ["imo"], name: "index_vessels_on_imo", unique: true, where: "(imo IS NOT NULL)"
  end

  add_foreign_key "certificate_requests", "crew_members"
  add_foreign_key "certificates", "certificate_types"
  add_foreign_key "certificates", "crew_members"
  add_foreign_key "certificates", "users", column: "verified_by_id"
  add_foreign_key "crew_members", "roles"
  add_foreign_key "crew_members", "vessels"
  add_foreign_key "matrix_requirements", "certificate_types"
  add_foreign_key "matrix_requirements", "roles"
  add_foreign_key "matrix_requirements", "vessels"
end
