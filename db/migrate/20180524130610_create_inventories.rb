class CreateInventories < ActiveRecord::Migration[5.1]
  def up
    create_table :inventories do |t|
      t.integer :partner_id, :null => false
      t.integer :room_id, :null => false
      t.integer :total_quantity, :null => false
      t.integer :booked_quantity
      t.integer :on_hold_quantity
      t.integer :status, :limit => 2, :null => false, :default => 0
      t.timestamps
    end

    add_index :inventories, [:partner_id, :room_id], :unique => true, :name => "UNIQUE"
    add_index :inventories, :room_id, :name => "index_on_room_id"
    add_index :inventories, :status, :name => "index_on_status"
  end

  def down
    drop_table :inventories
  end
end
