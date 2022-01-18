class DeviseCreateShopUsers < ActiveRecord::Migration[6.0]
  def change
    create_table(:shop_users) do |t|
      ## Database authenticatable
      t.string :username
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.timestamps
    end

    add_index :shop_users, :email,                 unique: true
    add_index :shop_users, :username,              unique: true
    add_index :shop_users, :reset_password_token,  unique: true
  end
end
