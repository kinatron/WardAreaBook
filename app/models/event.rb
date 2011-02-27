class Event < ActiveRecord::Base
  belongs_to :family;
  belongs_to :person;
  validates_presence_of :family_id
  include TeachingRecordsHelper

  def getCategory
    if memberMilestones.include?([self.category,self.category])
      "Milestone"
    elsif self.category == "Attend Church"
      "Attend<br>Church"
    else
      self.category
    end
  end

  def getComment
    wardRep = ""
    if self.person
      wardRep = self.person.full_name
    end
    if memberMilestones.include?([self.category,self.category])
      "#{wardRep} &ndash #{self.category}.  #{self.comment}"
    elsif self.comment and self.comment.size > 0
      "#{wardRep} &ndash #{self.comment}" 
    else
      "#{wardRep}" 
    end
  end
end
