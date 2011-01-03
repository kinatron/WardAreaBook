class StatsController < ApplicationController
  caches_action :index, :layout => false
  def index 
    @totalMembers  = Person.find_all_by_current(true).count
    @total         = Family.find_all_by_current_and_member(true,true, :conditions => "status != 'moved'").count
    @active        = Family.find_all_by_current_and_member_and_status(true,true,'active').count
    @lessActive    = Family.find_all_by_current_and_member_and_status(true,true,'less active').count
    @notInterested = Family.find_all_by_current_and_member_and_status(true,true,'not interested').count
    @dnc           = Family.find_all_by_current_and_member_and_status(true,true,'dnc').count
    @unknown       = Family.find_all_by_current_and_member_and_status(true,true,'unknown').count + 
                     Family.find_all_by_current_and_member_and_status(true,true,'new').count 
  end
end
