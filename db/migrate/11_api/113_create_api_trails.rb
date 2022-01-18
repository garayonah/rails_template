class CreateApiTrails < ActiveRecord::Migration[6.0]
  def change
    create_table :api_trails do |t|
      t.integer :api_client_id
      t.string :controller
      t.string :action

      t.string :remote_address
      t.string :user_agent
      
      t.string :request_headers
      t.string :request
      t.string :response

      t.string :message
      t.string :result_code

      t.timestamps null: false
    end
  end
end
