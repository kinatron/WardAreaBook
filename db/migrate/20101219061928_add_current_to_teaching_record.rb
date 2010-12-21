class AddCurrentToTeachingRecord < ActiveRecord::Migration
  def self.up
    add_column :teaching_records, :current, :boolean, :default => true 
    add_column :teaching_records, :organization, :string, :default => "Ward Mission" 
  end

  def self.down
    remove_column :teaching_records, :current
    remove_column :teaching_records, :organization
  end
end
