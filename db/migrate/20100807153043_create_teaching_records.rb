class CreateTeachingRecords < ActiveRecord::Migration
  def self.up
    create_table :teaching_records do |t|
      t.integer :family_id
      t.string :category
      t.string :lessons_taught
      t.date :last_lesson
      t.date :next_lesson
      t.integer :person_id
      t.string :membership_milestone
      t.date :milestone_date_goal

      t.timestamps
    end
  end

  def self.down
    drop_table :teaching_records
  end
end
