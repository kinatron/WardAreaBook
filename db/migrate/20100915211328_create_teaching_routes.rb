class CreateTeachingRoutes < ActiveRecord::Migration
  def self.up
    create_table :teaching_routes do |t|
      t.integer :family_id
      t.integer :person_id
      t.string  :category
    end
  end

  def self.down
    drop_table :teaching_routes 
  end
end
