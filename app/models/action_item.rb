class ActionItem < ActiveRecord::Base
  belongs_to :family;
  belongs_to :person;
  validates_presence_of :person

  def author
    Person.find(self.issuer_id).full_name
  end
end
