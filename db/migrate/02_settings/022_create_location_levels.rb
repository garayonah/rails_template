class CreateLocationLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :location_levels, { id: false } do |t|
			t.string :id, null: true
      t.string :code
			t.string :name

      t.timestamps null: true
    end

		execute "ALTER TABLE location_levels ADD PRIMARY KEY (id);"
  end
end
