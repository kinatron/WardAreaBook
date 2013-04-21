module TeachingRoutesHelper
  include VisitFindingHelper

  def familySuggestions(familyName)
    last, first = familyName.split(",").collect! {|x| x.strip}
    names = Array.new
    families = Family.find_all_by_name(last)
    families.each do |fam| 
      names << ([fam.name + ", " + fam.head_of_house_hold, fam.id])
    end
    names
  end

  def personSuggestions(personName)
    last, first = personName.split(",").collect! {|x| x.strip}
    names = Array.new
    families = Family.find_all_by_name(last)
    families.each do |fam| 
      fam.people.each do |person|
        if person.current
          names << ([person.name + " " + person.family.name, person.id])
        end
      end
    end
    names
  end

  def getHomeTeachingVisitDate(event)
    if event
      event.date.strftime("%m/%d/%y")
    else
      ""
    end
  end

  def getHomeTeachingVisitDateSortable(event)
    if event
      event.date.strftime("%Y%m%d")
    else
      ""
    end
  end


  def getLastHomeTeacherVisitColor(event)
    unless event == nil
      if event.date >= Date.today.at_beginning_of_month
        return "#00ff00"
      elsif event.date >= Date.today.months_ago(1).at_beginning_of_month
        return "cyan"
      elsif event.date >= Date.today.months_ago(2).at_beginning_of_month 
        return "yellow"
      end
    end
  end

end
