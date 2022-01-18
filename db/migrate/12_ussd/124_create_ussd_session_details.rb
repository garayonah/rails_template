class CreateUssdSessionDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :ussd_session_details do |t|
      t.integer :ussd_session_id
      t.string :name #age
      t.string :value #name

      t.timestamps null: false
    end
  end
end