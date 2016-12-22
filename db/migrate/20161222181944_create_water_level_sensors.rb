class CreateWaterLevelSensors < ActiveRecord::Migration[5.0]
  def change
    create_table :water_level_sensors do |t|

      t.timestamps
    end
  end
end
