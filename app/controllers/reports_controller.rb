class ReportsController < ApplicationController
  caches_action :hope, :monthlyReport, :allReports, :layout => false

  # override the application accessLevel method
  def checkAccess
    #only the ward council has access
    if hasAccess(2)
      true
    else
      deny_access
    end
  end

  # TODO reference the hopes by name not id 1
  def hope
    @events = Event.find_all_by_person_id(1).order('date DESC')
    @event_weeks = @events.group_by { |week| week.date.at_beginning_of_week }
  end

  def allReports
    @showLink = false
    @event_months = getMonthlyEvents(0)
    render :action=>"monthlyReport"
  end

  def monthlyReport
    @showLink = true
    range = 3.months.ago.at_beginning_of_month.to_date
    @event_months = getMonthlyEvents(range)
  end

  def getMonthlyEvents(range)
    @events = Event.where("(category != 'Attempt' and 
                             category != 'Other' and  
                             category != 'MoveIn' and
                             category != 'MoveOut' and
                             category is not NULL) and (date > ?)", range)
                             .order('date DESC')

    @event_months = @events.group_by { |month| month.date.at_beginning_of_month }
  end
end
