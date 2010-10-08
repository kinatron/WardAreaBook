class StatsController < ApplicationController
  caches_action :index, :layout => false

  def index 
    @total         = Family.find_all_by_current(true, :conditions => "status != 'moved'").count
    @active        = Family.find_all_by_current_and_status(true,'active').count
    @lessActive    = Family.find_all_by_current_and_status(true,'less active').count
    @notInterested = Family.find_all_by_current_and_status(true,'not interested').count
    @dnc           = Family.find_all_by_current_and_status(true,'dnc').count
    @unknown       = Family.find_all_by_current_and_status(true,'unknown').count + 
                     Family.find_all_by_current_and_status(true,'new').count 
  end

end
