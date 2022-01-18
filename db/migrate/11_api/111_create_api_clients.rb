class CreateApiClients < ActiveRecord::Migration[6.0]
  def change
    create_table :api_clients do |t| 
      t.string :name, limit: 64
      t.string :access_id, unique: true
      t.string :secret_key, unique: true
      t.integer :user_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps null: false
    end
  end
end
