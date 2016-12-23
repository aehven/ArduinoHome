class CreateGatewayMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :gateway_messages do |t|
      t.integer :node_id, limit: 1
      t.integer :child_sensor_id, limit: 1
      t.integer :message_type, limit: 1
      t.integer :ack, limit: 1
      t.integer :subtype, limit: 1
      t.string :payload

      t.timestamps
    end
  end
end
