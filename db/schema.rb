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

ActiveRecord::Schema.define(:version => 20100609160428) do

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
    t.integer  "ward_representative_id", :limit => 255
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
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
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.integer  "family_id"
    t.string   "phone"
    t.string   "email"
    t.string   "calling"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ward_representatives", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
