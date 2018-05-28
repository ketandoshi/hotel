class CreateRoomRates < ActiveRecord::Migration[5.1]
  def up
    create_table :room_rates do |t|
      t.date :rate_day, null: false
      t.integer :rate_day_timestamp, :null => false
      t.integer :partner_id, :null => false
      t.integer :room_id, :null => false
      t.decimal :rate_amount, :precision => 12, :scale => 2
      t.timestamps
    end

    add_index :room_rates, [:rate_day_timestamp, :partner_id, :room_id], :unique => true, :name => "UNIQUE"
    add_index :room_rates, :rate_day_timestamp, :name => "index_on_day"
    add_index :room_rates, :partner_id, :name => "index_on_partner"
  end

  def down
    drop_table :room_rates
  end
end
