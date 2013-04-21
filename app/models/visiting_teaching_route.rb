class VisitingTeachingRoute < ActiveRecord::Base
  belongs_to :visiting_teacher, :class_name => "Person"
  belongs_to :person

  attr_accessible :person_id, :visiting_teacher_id
end
