class AddTimeStampToTeachingRecords < ActiveRecord::Migration
  def self.up
    add_column :teaching_routes, :last_update, :date, :default => Date.today
  end

  def self.down
    remove_column :last_update
  end
end
