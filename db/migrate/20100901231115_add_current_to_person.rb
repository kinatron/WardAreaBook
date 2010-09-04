class AddCurrentToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :current, :boolean, :default => true
  end

  def self.down
    remove_column :people, :current
  end
end
