task :migrate_visits => :environment do
  uncategorized = 0

  Event.includes(:person => {}, :family => {:people => {:visiting_teachers => {} }}).where(:category => "Visit").each do |e|
    routes = TeachingRoute.find_all_by_family_id e.family_id
    new_category = nil
    routes.each do |r|
      if r.person_id == e.person_id
        new_category = "Home Teaching"
        break
      end
    end

    if new_category.nil?
      e.family.people.each do |p|
        p.visiting_teachers.each do |vt|
          if vt.id == e.person_id
            new_category = "Visiting Teaching"
            break
          end
        end
        break unless new_category.nil?
      end
    end

    if new_category.nil?
      uncategorized += 1
    else
      e.category = new_category
      e.save
    end
  end

  puts "Unable to categorize: #{uncategorized} visits"
end
