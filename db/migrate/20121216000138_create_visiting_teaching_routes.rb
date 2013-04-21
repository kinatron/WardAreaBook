class CreateVisitingTeachingRoutes < ActiveRecord::Migration
  def change
    create_table :visiting_teaching_routes do |t|
      t.integer :visiting_teacher_id
      t.integer :person_id

      t.timestamps
    end
  end
end
