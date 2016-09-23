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

ActiveRecord::Schema.define(version: 20110901203519) do

  create_table "custom_queries", force: :cascade do |t|
    t.string "name",  null: false
    t.text   "query", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.integer  "source_id",                                      null: false
    t.string   "original",          limit: 2048,                 null: false
    t.boolean  "parsed",                         default: false, null: false
    t.string   "server_name",       limit: 64
    t.string   "client_ip"
    t.datetime "access_time"
    t.float    "duration"
    t.string   "http_request",      limit: 2048
    t.string   "http_method"
    t.string   "http_url",          limit: 1024
    t.string   "http_query_string", limit: 1024
    t.integer  "status_code"
    t.string   "referrer",          limit: 2048
    t.string   "user_agent",        limit: 512
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_agent_type"
  end

  add_index "entries", ["access_time"], name: "index_entries_on_access_time"
  add_index "entries", ["source_id", "parsed", "access_time"], name: "index_entries_on_source_id_and_parsed_and_access_time"
  add_index "entries", ["source_id", "parsed"], name: "index_entries_on_source_id_and_parsed"
  add_index "entries", ["source_id"], name: "index_entries_on_source_id"

  create_table "sources", force: :cascade do |t|
    t.string   "filename",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count_entries"
    t.integer  "count_parsed_entries"
    t.integer  "count_unparsed_entries"
  end

  add_index "sources", ["filename"], name: "index_sources_on_filename", unique: true

end
