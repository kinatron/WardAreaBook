class Calling < ActiveRecord::Base
  #belongs_to :person
  has_many :calling_assignments, :dependent => :destroy
  has_many :people, :through => :calling_assignments

  attr_accessible :job, :person_id, :position_id, :access_level
end
