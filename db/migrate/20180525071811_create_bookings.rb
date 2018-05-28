class CreateBookings < ActiveRecord::Migration[5.1]
  def up
    create_table :bookings do |t|
      t.integer :user_id, :null => false
      t.integer :partner_id, :null => false
      t.integer :room_id, :null => false
      t.date :move_in_date, :null => false
      t.date :move_out_date, :null => false
      t.decimal :total_amount, :precision => 12, :scale => 2
      t.integer :booked_quantity
      t.timestamps
    end
  end

  def down
    drop_table :bookings
  end
end
