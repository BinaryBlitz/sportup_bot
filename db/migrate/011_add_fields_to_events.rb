class AddFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :sport_type, :string
    add_column :events, :team_limit, :integer
    add_column :events, :public, :boolean, default: true
    add_column :events, :password, :string
    add_column :events, :price, :integer, default: 0
  end
end
