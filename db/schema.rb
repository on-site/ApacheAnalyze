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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110825220356) do

  create_table "entries", :force => true do |t|
    t.integer  "source_id",                                      :null => false
    t.string   "original",     :limit => 512,                    :null => false
    t.boolean  "parsed",                      :default => false, :null => false
    t.string   "client_ip"
    t.datetime "access_time"
    t.float    "duration"
    t.string   "http_request"
    t.string   "http_method"
    t.string   "http_url"
    t.integer  "status_code"
    t.string   "referrer"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entries", ["access_time"], :name => "index_entries_on_access_time"
  add_index "entries", ["source_id", "parsed", "access_time"], :name => "index_entries_on_source_id_and_parsed_and_access_time"

  create_table "sources", :force => true do |t|
    t.string   "filename",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sources", ["filename"], :name => "index_sources_on_filename", :unique => true

end
