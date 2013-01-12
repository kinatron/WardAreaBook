class ActionItem < ActiveRecord::Base
  belongs_to :family
  belongs_to :person
  belongs_to :issuer, :class_name => "Person"

  attr_accessible :person_id, :family_id, :action, :due_date, :status, :comment

  validates_presence_of :person


  #TODO: Remove this method; I've added an 'issuer' association that gives a Person object rather than just the name, but I'm leaving this method as is for now so I don't break code somewhere else
  def author
    Person.find(self.issuer_id).full_name
  end
end
