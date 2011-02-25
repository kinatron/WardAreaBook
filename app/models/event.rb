class Event < ActiveRecord::Base
  belongs_to :family;
  belongs_to :person;
  validates_presence_of :family_id

end
