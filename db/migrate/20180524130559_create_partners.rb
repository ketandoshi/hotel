class CreatePartners < ActiveRecord::Migration[5.1]
  def up
    create_table :partners do |t|
      t.string :name, :null => false
      t.string :email, :limit => 200, :null => false
      t.timestamps
    end

    add_index :partners, :email, :unique => true, :name => "UNIQUE"
  end

  def down
    drop_table :partners
  end
end
