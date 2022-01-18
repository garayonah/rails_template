class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.decimal :price
      t.string :status, default: 'active'
      t.text :tags, array: true, default: []
      t.string :product_image_id
    end
  end
end
