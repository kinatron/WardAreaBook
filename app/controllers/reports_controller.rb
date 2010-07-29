class ReportsController < ApplicationController
  before_filter :store_return_point
  caches_action :hope, :month

  def hope
    @events = Event.find_all_by_person_id(1, :order => 'date DESC')
    @event_weeks = @events.group_by { |week| week.date.at_beginning_of_week }
  end

  def month
    @events = Event.find(:all, :conditions => "category == 'Visit' or category == 'Lesson'", 
                         :order => 'date DESC')
    @event_months = @events.group_by { |month| month.date.at_beginning_of_month }
  end

end
