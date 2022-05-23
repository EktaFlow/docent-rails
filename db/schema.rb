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

ActiveRecord::Schema.define(version: 2022_05_23_151917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.string "answer"
    t.integer "likelihood"
    t.integer "consequence"
    t.string "risk_response"
    t.string "greatest_impact"
    t.string "mmp_summary"
    t.string "objective_evidence"
    t.string "assumptions_yes"
    t.string "notes_yes"
    t.string "what"
    t.string "when"
    t.string "who"
    t.string "risk"
    t.string "reason"
    t.string "assumptions_no"
    t.string "documentation_no"
    t.string "assumptions_na"
    t.string "assumptions_skipped"
    t.string "notes_skipped"
    t.string "notes_no"
    t.string "notes_na"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.integer "question_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.string "name"
    t.text "scope"
    t.integer "target_mrl"
    t.integer "current_mrl"
    t.boolean "level_switching"
    t.date "target"
    t.string "location"
    t.string "deskbook_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "owner_id"
    t.string "threads", default: [], array: true
  end

  create_table "file_attachment_answers", force: :cascade do |t|
    t.integer "file_attachment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "question_id"
  end

  create_table "file_attachments", force: :cascade do |t|
    t.integer "assessment_id"
    t.string "file_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mr_threads", force: :cascade do |t|
    t.string "name"
    t.integer "mr_level"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "assessment_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "question_text"
    t.string "current_answer"
    t.boolean "skipped"
    t.boolean "answered"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "subthread_id"
  end

  create_table "subthreads", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "mr_thread_id"
    t.string "help_text"
    t.string "criteria_text"
    t.string "status"
  end

  create_table "team_members", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "assessment_id", null: false
    t.string "role"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: 6
    t.datetime "confirmation_sent_at", precision: 6
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "assessments", "users", column: "owner_id"
  add_foreign_key "file_attachment_answers", "file_attachments"
  add_foreign_key "file_attachment_answers", "questions"
  add_foreign_key "file_attachments", "assessments"
  add_foreign_key "mr_threads", "assessments"
  add_foreign_key "questions", "subthreads"
  add_foreign_key "subthreads", "mr_threads"
end
