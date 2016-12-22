class CreateMotionSensors < ActiveRecord::Migration[5.0]
  def change
    create_table :motion_sensors do |t|

      t.timestamps
    end
  end
end
