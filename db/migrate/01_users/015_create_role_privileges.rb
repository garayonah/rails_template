class CreateRolePrivileges < ActiveRecord::Migration[6.0]
  def change
    create_table :role_privileges do |t|
      t.integer :role_id, :null=>false
      t.integer :privilege_id, :null=>false
      t.string :status, :default => 'active'
      t.timestamps null: false
    end
  end
end