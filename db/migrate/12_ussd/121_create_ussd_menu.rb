class CreateUssdMenu < ActiveRecord::Migration[6.0]
  def change
    create_table :ussd_menus do |t|
      t.string :name, :unique => true, :null=>false
      t.string :text_en #"Welcome to BK\n1.BK Quick\n2.Send Money"
      t.string :text_fr #"Beinvenue a BK\n1.BK Rapide\n2.Envoyer de L'Argent"
      t.string :text_rw #"Murakaza Neza Muri BK\n1.BK Yihuta\n2.Kohereza Amafaranga"
      t.boolean :end_request

      t.timestamps null: false
    end
  end
end
