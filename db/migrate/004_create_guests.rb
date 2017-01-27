class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.references :user, index: true, null: false
      t.references :event, index: true, null: false
      t.integer :team_number

      t.timestamps
    end

    add_foreign_key :guests, :users
    add_foreign_key :guests, :events
  end
end
