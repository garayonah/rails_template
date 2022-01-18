class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.string :name, :unique => true, :null=>false
      t.string :value, :null=>false
      t.string :description
      t.string :restrictions
      t.integer :updated_by_id

      t.timestamps null: false
    end
  end
end
