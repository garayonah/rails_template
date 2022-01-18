class CreatePrivileges < ActiveRecord::Migration[6.0]
  def change
    create_table :privileges do |t|
      t.string :name, :unique => true, :null=>false
      t.string :description
      t.string :group
      t.timestamps null: false
    end
  end
end
