class CreateRooms < ActiveRecord::Migration[5.1]
  def up
    create_table :rooms do |t|
      t.string :room_type, :null => false
      t.integer :occupancy, :limit => 2, :null => false
      t.timestamps
    end

    add_index :rooms, :room_type, :unique => true, :name => "UNIQUE"
  end

  def down
    drop_table :rooms
  end
end
