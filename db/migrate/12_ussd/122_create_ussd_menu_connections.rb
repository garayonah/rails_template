class CreateUssdMenuConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :ussd_menu_connections do |t|
      t.integer :from_menu_id
      t.boolean :new_request
      t.integer :to_menu_id
      t.string :call_function
      t.string :input
      t.string :save_input_as #save input to ussd_session_fields

      t.timestamps null: false
    end
  end
end
