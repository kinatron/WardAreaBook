class Calling < ActiveRecord::Base
  belongs_to :person

  attr_accessible :job, :person_id, :position_id, :access_level
end
