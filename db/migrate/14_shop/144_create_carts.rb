class CreateCarts < ActiveRecord::Migration[6.0]
  def change
    create_table :carts do |t|
      t.integer :shop_user_id
      t.integer :number_of_products
      t.decimal :total_price
    end
  end
end
