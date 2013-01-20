class Event < ActiveRecord::Base
  belongs_to :family;
  belongs_to :person;

  attr_accessible :date, :family_id, :person_id, :category, :comment

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

  def getHomeTeachers
    homeTeachers = Array.new
    if self.family.teaching_routes.size == 0
      # TODO get this more explicitly
      
      homeTeachers << Calling.find_by_job("Elders Quorum President")
      homeTeachers << Calling.find_by_job("High Priest Group Leader")
    else
      self.family.teaching_routes.each do |route|
        homeTeachers << route.person
      end
    end
    homeTeachers
  end

  def getEventDisplay
    if self.person 
      wardRep = self.person.full_name + " -- "
    else
      wardRep = ""
    end
    "#{self.date} -- #{wardRep}#{self.category} -- #{self.comment}"
  end

end
