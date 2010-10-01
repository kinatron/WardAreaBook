module TeachingRoutesHelper
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

  def getLastHomeTeacherVisit(family)
    family.events.find(:first, 
                       :conditions => ["(person_id = ? or person_id = ?) and 
                                        (category = 'Visit' or category = 'Lesson')",
                                       family.teaching_routes[0].person.id,
                                       family.teaching_routes[1].person.id ],
                       :order => 'date DESC' )
  end

end
