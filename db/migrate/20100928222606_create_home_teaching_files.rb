class CreateHomeTeachingFiles < ActiveRecord::Migration
  def self.up
    create_table :home_teaching_files do |t|
      t.string :location
      t.timestamps
    end
  end

  def self.down
    drop_table :home_teaching_files
  end
end
