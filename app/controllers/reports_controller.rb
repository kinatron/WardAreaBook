class ReportsController < ApplicationController

  def hope
    @events = Event.find_all_by_ward_representative_id(1, :order => 'date ASC')
    @event_weeks = @events.group_by { |week| week.date.at_beginning_of_week }
  end

  def month
  end

end
