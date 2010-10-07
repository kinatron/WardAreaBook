module StatsHelper
  def familiesVisited(monthsAgo)
    targetDate = Date.today.months_ago(monthsAgo).at_beginning_of_month
    events = Event.find(:all, 
                        :conditions => ["(category == 'Visit' or category == 'Lesson') 
                                          and date >=?", targetDate])

    events.delete_if {|x| x.family.current==false or x.family.status=='moved'}
    families = events.group_by { |family| family.family_id}
    families.keys.size
  end

  def getPercentage(num, total)
    ((num.to_f/total.to_f)*100).round
  end
end
