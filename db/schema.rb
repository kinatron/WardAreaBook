# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110404043937) do

  create_table "action_items", :force => true do |t|
    t.integer  "family_id"
    t.integer  "person_id"
    t.integer  "issuer_id"
    t.text     "action"
    t.date     "due_date"
    t.string   "status",     :default => "open"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "callings", :force => true do |t|
    t.string   "job"
    t.integer  "person_id"
    t.integer  "access_level", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "family_id"
    t.integer  "person_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companionships", :force => true do |t|
    t.string   "type"
    t.integer  "person1"
    t.integer  "person2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.date     "date"
    t.integer  "family_id"
    t.integer  "person_id"
    t.string   "category"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author",     :default => 1
  end

  create_table "families", :force => true do |t|
    t.string   "name"
    t.string   "head_of_house_hold"
    t.string   "phone"
    t.string   "address"
    t.string   "status"
    t.text     "information"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",            :default => true
    t.boolean  "member",             :default => true
    t.string   "uid"
  end

  create_table "home_teaching_files", :force => true do |t|
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "name_mappings", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.integer  "person_id"
    t.integer  "family_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.integer  "family_id"
    t.string   "phone"
    t.string   "email"
    t.string   "calling"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",    :default => true
  end

  create_table "root_admins", :force => true do |t|
    t.integer  "person_id"
    t.string   "lds_user_name"
    t.string   "lds_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "teaching_records", :force => true do |t|
    t.integer  "family_id"
    t.string   "category"
    t.string   "lessons_taught"
    t.date     "last_lesson"
    t.date     "next_lesson"
    t.integer  "person_id"
    t.string   "membership_milestone"
    t.date     "milestone_date_goal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current",              :default => true
    t.string   "organization",         :default => "Ward Mission"
  end

  create_table "teaching_routes", :force => true do |t|
    t.integer "family_id"
    t.integer "person_id"
    t.string  "category"
    t.date    "last_update", :default => '2011-02-24'
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.boolean  "logged_in_now",       :default => false
    t.string   "persistence_token",   :default => "",    :null => false
    t.string   "perishable_token",    :default => "",    :null => false
    t.string   "single_access_token", :default => "",    :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.boolean  "verified",            :default => false
  end

  create_table "ward_profiles", :force => true do |t|
    t.date     "quarter"
    t.integer  "total_families"
    t.integer  "active"
    t.integer  "less_active"
    t.integer  "unknown"
    t.integer  "not_interested"
    t.integer  "dnc"
    t.integer  "new"
    t.integer  "moved"
    t.integer  "visited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
