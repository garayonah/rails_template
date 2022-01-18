class CreateToDos < ActiveRecord::Migration[6.0]
  def change
    create_table :to_dos do |t|
      t.integer :priority
      t.string :name, unique: true, null: false
      t.string :progress
      t.string :status, default: 'active'
    end
  end
end
