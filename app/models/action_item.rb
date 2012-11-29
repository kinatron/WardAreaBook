class ActionItem < ActiveRecord::Base
  belongs_to :family;
  belongs_to :person;

  attr_accessible :person_id, :family_id, :action, :due_date, :status, :comment

  validates_presence_of :person

  def author
    Person.find(self.issuer_id).full_name
  end
end
