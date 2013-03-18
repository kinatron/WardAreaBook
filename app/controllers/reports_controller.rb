class ReportsController < ApplicationController

  # override the application accessLevel method
  def checkAccess
    #only the ward council and org. leadership have access
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
    allowed_reports = allowedReports
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
      hp, elders, vt, unassigned = categorizeVisits(events_by_families)

      visit_count = 0
      if allowed_reports.include? :hp
        month_info[:hp] = hp
        visit_count += hp.size
      end
      if allowed_reports.include? :elders
        month_info[:elders] = elders
        visit_count += elders.size
      end
      if allowed_reports.include? :vt
        month_info[:vt] = vt
        visit_count += vt.size
      end
      if allowed_reports.include? :unassigned
        month_info[:unassigned] = unassigned
        visit_count += unassigned.size
      end
      monthly_info << month_info
      month_info[:families_visited_count] = visit_count
    end
    monthly_info
  end

  private

  def categorizeVisits(family_events)
    elders = Array.new
    hp = Array.new
    vt = Array.new
    unassigned = Array.new
    family_events.each do |family_id, events|
      family = Family.find(family_id)
      vt_events = Array.new
      ht_events = Array.new
      other_events = Array.new

      events.each do |e|
        if e.category == "Visiting Teaching"
          vt_events << e
          puts "VT Event"
        elsif e.category == "Home Teaching"
          ht_events << e
          puts "HT Event"
        else
          other_events << e
          puts "Other Event"
        end
      end

      unless vt_events.empty?
        vt << [family_id, vt_events]
      end

      unless ht_events.empty?
        if family.teaching_routes.size == 0
          other_events.concat ht_events
        elsif family.teaching_routes[0].category == "High Priests Group"
          hp << [family_id, ht_events]
        elsif family.teaching_routes[0].category == "Elders Quorum"
          elders << [family_id, ht_events]
        else
          other_events.concat ht_events
        end
      end

      unless other_events.empty?
        unassigned << [family_id, other_events]
      end

    end
    return hp, elders, vt, unassigned
  end

  def allowedReports
    if hasAccess(3)
      allowed_reports = [:unassigned, :vt, :hp, :elders]
    else
      ward_council =  ['4', '54', '55', '56', '57', '143', '133', '138', '221', '210', '183', '158', '204']
      calling_report_access = {
        unassigned: ward_council,
        vt: ward_council + ['143', '144', '145', '146', '151'],
        hp: ward_council + ['133', '134', '135', '1395'],
        elders: ward_council + ['138', '139', '140', '141']
      }
      allowed_reports = Array.new
      pos_ids = current_user.person.callings.map {|c| c.position_id}
      pos_ids.each do |pid|
        calling_report_access.keys.each do |key|
          if calling_report_access[key].include? pid
            allowed_reports << key
          end
        end
      end
    end
    allowed_reports
  end

end
