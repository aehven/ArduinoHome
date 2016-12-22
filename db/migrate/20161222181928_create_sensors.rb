class CreateSensors < ActiveRecord::Migration[5.0]
  def change
    create_table :sensors do |t|
      t.actable

      t.model_name :string
      t.description :string
      t.location :string

      t.timestamps
    end
  end
end
