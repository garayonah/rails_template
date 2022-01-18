class AddAdditionalFieldsToUsers < ActiveRecord::Migration[6.0]
  change_table(:users) do |t|
    t.string :firstname, null: false
    t.string :lastname, null: false
    t.string :phone_number
    t.string :status, :default => 'active'
    t.integer :role_id, null: false
    t.integer :created_by_id
    t.integer :updated_by_id
  end
end
