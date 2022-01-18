# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_client_privileges", force: :cascade do |t|
    t.integer "api_client_id", null: false
    t.integer "privilege_id", null: false
    t.string "status", default: "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "api_clients", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "access_id"
    t.string "secret_key"
    t.integer "user_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "api_trails", force: :cascade do |t|
    t.integer "api_client_id"
    t.string "controller"
    t.string "action"
    t.string "remote_address"
    t.string "user_agent"
    t.string "request_headers"
    t.string "request"
    t.string "response"
    t.string "message"
    t.string "result_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cart_products", force: :cascade do |t|
    t.integer "cart_id"
    t.integer "product_id"
    t.integer "product_quantity"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "shop_user_id"
    t.integer "number_of_products"
    t.decimal "total_price"
  end

  create_table "location_levels", id: :string, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "locations", id: :string, force: :cascade do |t|
    t.string "code"
    t.string "coordinates"
    t.string "location_level_id"
    t.string "name"
    t.string "parent_id"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "privileges", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "price"
    t.string "status", default: "active"
    t.text "tags", default: [], array: true
    t.string "product_image_id"
  end

  create_table "role_privileges", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "privilege_id", null: false
    t.string "status", default: "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "status", default: "active"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "name", null: false
    t.string "value", null: false
    t.string "description"
    t.string "restrictions"
    t.integer "updated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shop_users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "phone_number"
    t.string "status", default: "active"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["email"], name: "index_shop_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_shop_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_shop_users_on_username", unique: true
  end

  create_table "to_dos", force: :cascade do |t|
    t.integer "priority"
    t.string "name", null: false
    t.string "progress"
    t.string "status", default: "active"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "phone_number"
    t.string "status", default: "active"
    t.integer "role_id", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "ussd_menu_connections", force: :cascade do |t|
    t.integer "from_menu_id"
    t.boolean "new_request"
    t.integer "to_menu_id"
    t.string "call_function"
    t.string "input"
    t.string "save_input_as"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ussd_menus", force: :cascade do |t|
    t.string "name", null: false
    t.string "text_en"
    t.string "text_fr"
    t.string "text_rw"
    t.boolean "end_request"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ussd_session_details", force: :cascade do |t|
    t.integer "ussd_session_id"
    t.string "name"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ussd_sessions", force: :cascade do |t|
    t.string "mobile_number", null: false
    t.integer "ussd_menu_id"
    t.string "menu_code"
    t.string "locale"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
