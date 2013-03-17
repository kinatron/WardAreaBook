module EventsHelper
  def eventCategories 
    [
      ["Home Teaching"  , "Home Teaching"], 
      ["Visiting Teaching"  , "Visiting Teaching"], 
      ["Attempt", "Attempt"],
      ["Other", "Other"]
    ]
  end

  def getNextMileStone(family)
    memberMilestones.each do |milestone|
      if family.events.find_by_category(milestone[0])
        next
      else
        return milestone unless milestone[0] == "Baptized" and family.member
      end
    end
  end

  def getEvents(family)
    if family.teaching_record and family.teaching_record.current
      teachingRecordEvents + memberMilestones
    else
      eventCategories
    end
  end

end
