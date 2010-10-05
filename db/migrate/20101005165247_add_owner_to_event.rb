class AddOwnerToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :author, :integer, :default => 1
  end

  def self.down
    remove_column :events, :author
  end
end
