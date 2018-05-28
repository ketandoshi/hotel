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

ActiveRecord::Schema.define(version: 20180528082746) do

  create_table "bookings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false
    t.integer "partner_id", null: false
    t.integer "room_id", null: false
    t.datetime "move_in_date", null: false
    t.datetime "move_out_date", null: false
    t.decimal "total_amount", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "partner_id", null: false
    t.integer "room_id", null: false
    t.integer "total_quantity", null: false
    t.integer "booked_quantity"
    t.integer "on_hold_quantity"
    t.integer "status", limit: 2, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id", "room_id"], name: "UNIQUE", unique: true
    t.index ["room_id"], name: "index_on_room_id"
    t.index ["status"], name: "index_on_status"
  end

  create_table "partners", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "email", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "UNIQUE", unique: true
  end

  create_table "room_rate_averages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "inventory_id", null: false
    t.integer "rate_month", limit: 2, null: false
    t.decimal "month_average_rate", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id", "rate_month"], name: "UNIQUE", unique: true
    t.index ["inventory_id"], name: "index_on_inventory_id"
  end

  create_table "room_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date "rate_day", null: false
    t.integer "rate_day_timestamp", null: false
    t.integer "partner_id", null: false
    t.integer "room_id", null: false
    t.decimal "rate_amount", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "index_on_partner"
    t.index ["rate_day_timestamp", "partner_id", "room_id"], name: "UNIQUE", unique: true
    t.index ["rate_day_timestamp"], name: "index_on_day"
  end

  create_table "rooms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "room_type", null: false
    t.integer "occupancy", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_type"], name: "UNIQUE", unique: true
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "UNIQUE", unique: true
  end

end
