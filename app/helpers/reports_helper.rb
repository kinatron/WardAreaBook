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
end
