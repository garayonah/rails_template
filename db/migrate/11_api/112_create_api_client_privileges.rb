class CreateApiClientPrivileges < ActiveRecord::Migration[6.0]
  def change
    create_table :api_client_privileges do |t|
      t.integer :api_client_id, :null=>false
      t.integer :privilege_id, :null=>false
      t.string :status, :default => 'active'
      t.timestamps null: false
    end
  end
end