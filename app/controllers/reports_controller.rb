class ReportsController < ApplicationController

  # override the application accessLevel method
  def checkAccess
    #only the ward council has access
    if hasAccess(2)
      true
    else
      deny_access
    end
  end

  def allReports
    @showLink = false
    @monthly_info = getMonthlyEvents(0)
    @names = Person.selectionList
    render :action=>"monthlyReport"
  end

  def monthlyReport
    @showLink = true
    range = 3.months.ago.at_beginning_of_month.to_date
    @monthly_info = getMonthlyEvents(range)
    @names = Person.selectionList
  end

  def getMonthlyEvents(range)
    @events = Event.includes(:family => { :teaching_routes => {} }).where("(category != 'Attempt' and 
                             category != 'Other' and  
                             category != 'MoveIn' and
                             category != 'MoveOut' and
                             category is not NULL) and (date > ?)", range)
                             .order('date DESC')

    monthly_info = []

    event_months = @events.group_by { |month| month.date.at_beginning_of_month }
    event_months.each do |month, events|
      month_info = {:month => month}
      events.sort! { |a,b| a.family.name <=> b.family.name }
      events_by_families = events.group_by { |event| event.family_id }
      hp, elders, unassigned = categorizeVisits(events_by_families)

      month_info[:families_visited_count] = events_by_families.keys.size
      month_info[:hp] = hp
      month_info[:elders] = elders
      month_info[:unassigned] = unassigned
      monthly_info << month_info
    end

    monthly_info
  end

  private

  def categorizeVisits(family_events)
    elders = Array.new
    hp = Array.new
    unassigned = Array.new
    family_events.each do |family_id, events| 
      family = Family.find(family_id)
      if family.teaching_routes.size == 0
        unassigned << [family_id, events]
      elsif family.teaching_routes[0].category == "High Priests Group"
        hp << [family_id, events]
      elsif family.teaching_routes[0].category == "Elders Quorum"
        elders << [family_id, events]
      else
        unassigned << [family_id, events]
      end
    end
    return hp, elders, unassigned
  end

end
