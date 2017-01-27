class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user, index: true, null: false
      t.references :event, index: true, null: false
      t.integer :team_number

      t.timestamps null: false
    end

    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :events
  end
end
