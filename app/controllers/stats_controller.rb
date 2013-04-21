class StatsController < ApplicationController
  before_filter :findInfo
  def index 
    @families= Family.find_all_by_current_and_member_and_status(true,true,'active')
  end

  def showActive
    @families = Family.where(:status => 'active', :member => true, :current => true).order("name")
    render "index"
  end

  def showLessActive
    @families = Family.where(:status => 'less active', :member => true, :current => true).order("name")
    render "index"
  end

  def showNotInterested
    @families = Family.where(:status => 'not interested', :member => true, :current => true).order("name")
    render "index"
  end

  def showDNC
    @families = Family.where(:status => 'dnc', :member => true, :current => true).order("name")
    render "index"
  end

  def showUnknown
    @families = Family.where(:status => 'new', :member => true, :current => true).order("name")
    render "index"
  end

  def showThisMonth
    @families = Family.visitedWithinTheLastMonths(0)
    render "index"
  end

  def showTwoMonths
    @families = Family.visitedWithinTheLastMonths(1)
    render "index"
  end

  def showThreeMonths
    @families = Family.visitedWithinTheLastMonths(3)
    render "index"
  end

  def showSixMonths
    @families = Family.visitedWithinTheLastMonths(6)
    render "index"
  end

  def showYear
    @families = Family.visitedWithinTheLastMonths(12)
    render "index"
  end

  private

  def findInfo
    @totalMembers  = Person.find_all_by_current(true).length
    @total         = Family.where("status != 'moved'").where(:current => true, :member => true).length
    @active        = Family.find_all_by_current_and_member_and_status(true,true,'active').length
    @lessActive    = Family.find_all_by_current_and_member_and_status(true,true,'less active').length
    @notInterested = Family.find_all_by_current_and_member_and_status(true,true,'not interested').length
    @dnc           = Family.find_all_by_current_and_member_and_status(true,true,'dnc').length
    @unknown       = Family.find_all_by_current_and_member_and_status(true,true,'unknown').length + 
                     Family.find_all_by_current_and_member_and_status(true,true,'new').length 
  end
end
