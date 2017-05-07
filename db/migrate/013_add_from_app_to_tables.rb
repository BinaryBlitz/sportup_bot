class AddFromAppToTables < ActiveRecord::Migration
  def change
    add_column :guests, :from_app, :boolean, default: false
    add_column :memberships, :from_app, :boolean, default: false
  end
end
