class ReportsController < ApplicationController
  before_filter :store_return_point
  caches_action :hope, :monthlyReport, :allMonthlyReports, :layout => false

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
    @events = Event.find_all_by_person_id(1, :order => 'date DESC')
    @event_weeks = @events.group_by { |week| week.date.at_beginning_of_week }
  end

  def monthlyReport
    @showAll = false
    if params[:all]
      @showAll = true
      range = 0
    else
      range = 3.months.ago.at_beginning_of_month.to_date
    end
    @events = Event.find(:all, :conditions => ["(category != 'Attempt' and 
                                                 category != 'Other' and  
                                                 category != 'MoveIn' and
                                                 category != 'MoveOut' and
                                                 category is not NULL) and (date > ?)", range],
                         :order => 'date DESC')
    @event_months = @events.group_by { |month| month.date.at_beginning_of_month }
  end
end
