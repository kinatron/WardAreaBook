class StatsController < ApplicationController
  caches_action :index, :layout => false

  def index 
    @total         = Family.find_all_by_current(true, :conditions => "status != 'moved'").length
    @totalMembers  = Person.find_all_by_current(true).length
    @active        = Family.find_all_by_current_and_status(true,'active').length
    @lessActive    = Family.find_all_by_current_and_status(true,'less active').length
    @notInterested = Family.find_all_by_current_and_status(true,'not interested').length
    @dnc           = Family.find_all_by_current_and_status(true,'dnc').length
    @unknown       = Family.find_all_by_current_and_status(true,'unknown').length + 
                     Family.find_all_by_current_and_status(true,'new').length 
  end

end
