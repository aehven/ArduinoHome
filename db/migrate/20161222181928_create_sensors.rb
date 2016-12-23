class CreateSensors < ActiveRecord::Migration[5.0]
  def change
    create_table :sensors do |t|
      t.actable

      t.string :model_number
      t.string :description
      t.string :location

      t.timestamps
    end
  end
end
