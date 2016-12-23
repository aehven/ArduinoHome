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

ActiveRecord::Schema.define(version: 20161223003833) do

  create_table "gateway_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "node_id",         limit: 1
    t.integer  "child_sensor_id", limit: 1
    t.integer  "message_type",    limit: 1
    t.integer  "ack",             limit: 1
    t.integer  "subtype",         limit: 1
    t.string   "payload"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "homes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "motion_sensors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
  end

  create_table "sensors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "actable_type"
    t.integer  "actable_id"
    t.string   "model_number"
    t.string   "description"
    t.string   "location"
    t.integer  "node_id",         limit: 1
    t.integer  "child_sensor_id", limit: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["actable_type", "actable_id"], name: "index_sensors_on_actable_type_and_actable_id", using: :btree
  end

  create_table "water_level_sensors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
  end

end
