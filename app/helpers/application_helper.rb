# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  class Access
    ADMIN=3
    Missionary=2
    PEC=1
    General=0
  end

  def hasAccess(value)
    session[:access_level] > value 
  end

  def hasAccess(value,family)
    session[:access_level] > value 
    # TODO or if the session[user_id] is the home teacher of this family.
  end

  def getWardRepresentative(id)
    begin
      Person.find(id).name
    rescue
      "Error with id " + id.to_s
    end
  end

  

end
