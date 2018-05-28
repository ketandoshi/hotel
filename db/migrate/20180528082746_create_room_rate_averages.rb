class CreateRoomRateAverages < ActiveRecord::Migration[5.1]
  def up
    create_table :room_rate_averages do |t|
      t.integer :inventory_id, :null => false
      t.integer :rate_month, :limit => 2, :null => false
      t.decimal :month_average_rate, :precision => 12, :scale => 2
      t.timestamps
    end

    add_index :room_rate_averages, [:inventory_id, :rate_month], :unique => true, :name => "UNIQUE"
    add_index :room_rate_averages, :inventory_id, :name => "index_on_inventory_id"
  end

  def down
    drop_table :room_rate_averages
  end
end
