class Comment < ActiveRecord::Base
  belongs_to :family
  belongs_to :person


  attr_accessible :text, :person_id, :family_id
end
