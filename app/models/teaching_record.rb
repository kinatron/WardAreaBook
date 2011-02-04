class TeachingRecord < ActiveRecord::Base
  belongs_to :family
  belongs_to :person
  serialize :lessons_taught
  validates_uniqueness_of :family_id, :message => "This family already has a teaching record created."
  validates_presence_of :family_id, :message => "You must select a family to create a teaching record"
end
