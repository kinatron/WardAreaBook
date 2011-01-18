module ReportsHelper
  def categorizeVisits(visits)
    elders = Array.new
    hp = Array.new
    unassigned = Array.new
    visits.each do |family_id, events| 
      family = Family.find(family_id)
      if family.teaching_routes.size == 0
        unassigned << [family_id, events]
      elsif family.teaching_routes[0].category == "High Priests"
        hp << [family_id, events]
      elsif family.teaching_routes[0].category == "Elders"
        elders << [family_id, events]
      else
        unassigned << [family_id, events]
      end
    end
    return hp, elders, unassigned
  end

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
