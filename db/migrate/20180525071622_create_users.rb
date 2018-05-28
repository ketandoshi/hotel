class CreateUsers < ActiveRecord::Migration[5.1]
  def up
    create_table :users do |t|
      t.string :email, :limit => 200, :null => false
      t.timestamps
    end

    add_index :users, :email, :unique => true, :name => "UNIQUE"
  end

  def down
    drop_table :users
  end
end
