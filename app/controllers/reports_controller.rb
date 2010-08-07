class ReportsController < ApplicationController
  before_filter :store_return_point
  caches_action :hope, :month

  # override the application accessLevel method
   def checkAccess
     # Everybody has access to these methods
   end


  # TODO reference the hopes by name not id 1
  def hope
    @events = Event.find_all_by_person_id(1, :order => 'date DESC')
    @event_weeks = @events.group_by { |week| week.date.at_beginning_of_week }
  end

  def month
    @events = Event.find(:all, :conditions => "category == 'Visit' or category == 'Lesson'", 
                         :order => 'date DESC')
    @event_months = @events.group_by { |month| month.date.at_beginning_of_month }
  end
  def print
    # TODO have the specific week sent to me
    @week = Date.parse(params[:date])
    @events = Event.find_all_by_person_id(1, :conditions => {:date => @week..@week.advance(:days => 6)}, 
                                             :order => 'date DESC')
    render :layout => 'print'
  end

end
