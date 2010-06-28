module ReportsHelper

  def getWeeklyTotal(events,type)
    count =0;
    events.each do |element|
      if element.category == type 
        count += 1
      end
    end
    count
  end
  def getMonthlyTotal (events)
    families_visited = events.group_by { |event| event.family_id }
    families_visited.keys.size

    
  end
end
