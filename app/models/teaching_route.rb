class TeachingRoute < ActiveRecord::Base
  belongs_to :family
  belongs_to :person

  attr_accessible :category, :person_id, :family_id
end
