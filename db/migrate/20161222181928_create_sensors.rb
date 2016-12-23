class CreateSensors < ActiveRecord::Migration[5.0]
  def change
    create_table :sensors do |t|
      t.actable

      t.string :model_number
      t.string :description
      t.string :location

      t.integer :node_id, limit: 1
      t.integer :child_sensor_id, limit: 1

      t.timestamps
    end
  end
end
