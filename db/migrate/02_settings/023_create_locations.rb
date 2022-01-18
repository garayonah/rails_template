class CreateLocations < ActiveRecord::Migration[6.0]
  def change
		
    create_table :locations, {id: false} do |t|
			t.string :id, null: true
      t.string :code, unique: true
      t.string :coordinates
      #t.string :level
      t.string :location_level_id
      t.string :name
      t.string :parent_id

      t.timestamps null: true
    end

		execute "ALTER TABLE locations ADD PRIMARY KEY (id);"
  end
end
