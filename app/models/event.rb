class Event < ActiveRecord::Base
  belongs_to :family;
  belongs_to :person;
  validates_presence_of :family_id

  def printPerson
    begin
    # TODO hope hack
    if self.person.id == 1
      "The Hopes"
    elsif self.person.id == 2
      "The Elders"
    else 
      person.name.split(" ")[0] + " " + person.family.name
    end
    rescue
      #TODO log this
      ""
    end 
  end

end
