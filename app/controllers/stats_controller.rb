class StatsController < ApplicationController
  caches_action :index, :layout => false
  def index 
    @totalMembers  = Person.find_all_by_current(true).length
    @total         = Family.find_all_by_current_and_member(true,true, :conditions => "status != 'moved'").length
    @active        = Family.find_all_by_current_and_member_and_status(true,true,'active').length
    @lessActive    = Family.find_all_by_current_and_member_and_status(true,true,'less active').length
    @notInterested = Family.find_all_by_current_and_member_and_status(true,true,'not interested').length
    @dnc           = Family.find_all_by_current_and_member_and_status(true,true,'dnc').length
    @unknown       = Family.find_all_by_current_and_member_and_status(true,true,'unknown').length + 
                     Family.find_all_by_current_and_member_and_status(true,true,'new').length 
  end
end
