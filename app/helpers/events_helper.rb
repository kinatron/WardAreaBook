module EventsHelper
  def eventCategories 
    [
      ["Visit"  , "Visit"], 
      ["Lesson" , "Lesson"], 
      ["Attempt", "Attempt"],
      ["Other", "Other"]
    ]
  end

  def getNextMileStone(family)
    memberMilestones.each do |milestone|
      if family.events.find_by_category(milestone[0])
        next
      else
        return milestone
      end
    end
  end

end
