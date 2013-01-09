class Calling < ActiveRecord::Base
  has_many :calling_assignments, :dependent => :destroy
  has_many :people, :through => :calling_assignments

  attr_accessible :job, :position_id, :access_level
end
