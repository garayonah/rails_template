class CreateUssdSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :ussd_sessions do |t|
      t.string :mobile_number, :null=>false
      t.integer :ussd_menu_id
      t.string :menu_code
      t.string :locale

      t.timestamps null: false
    end
  end
end