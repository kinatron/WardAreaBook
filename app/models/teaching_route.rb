class TeachingRoute < ActiveRecord::Base
  belongs_to :family
  belongs_to :person
end
