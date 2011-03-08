module StatsHelper
  #TODO refactor these three methods
  def familiesVisited(monthsAgo)
    Family.visitedWithinTheLastMonths(monthsAgo).size
  end

  def moveOuts(periodInMonths)
    targetDate = Date.today.months_ago(periodInMonths).at_beginning_of_month
    events = Event.find(:all, 
                        :conditions => ["(category == 'MoveOut') 
                                          and date >=?", targetDate])
    families = events.group_by { |family| family.family_id}
    families.keys.size
  end

  def moveIns(periodInMonths)
    targetDate = Date.today.months_ago(periodInMonths).at_beginning_of_month
    events = Event.find(:all, 
                        :conditions => ["(category == 'MoveIn') 
                                          and date >=?", targetDate])
    families = events.group_by { |family| family.family_id}
    families.keys.size
  end

  def getPercentage(num, total)
    ((num.to_f/total.to_f)*100).round
  end
end
