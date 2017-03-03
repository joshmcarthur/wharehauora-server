class AddRoomsAgain < ActiveRecord::Migration
  def change
    add_column :sensors, :room_id, :int, null: false
    add_column :readings, :room_id, :int, null: false
    add_column :rooms, :active, :boolean, default: true

    add_foreign_key :sensors, :rooms
    add_foreign_key :readings, :rooms
  end
end
