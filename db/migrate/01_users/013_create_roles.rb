class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false, unique: true
      t.string :description
      t.string :status, :default => 'active'
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end