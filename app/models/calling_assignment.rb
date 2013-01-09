class CallingAssignment < ActiveRecord::Base
  attr_accessible :calling_id, :person_id
  validates_uniqueness_of :calling_id, scope: :person_id, message: "^Cannot assign the same calling to an individual more than once."
  belongs_to :calling
  belongs_to :person
end
