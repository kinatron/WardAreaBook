# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

include RedirectBack
class ApplicationController < ActionController::Base
  before_filter :authorize, :checkAccess, :except => :login
  helper :all # include all helpers, all the time

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "WardAreaBook"

  # Minutes of inactivity before relogin
  INACTIVITY_PERIOD = 60
  CLOSED_ACTION_LIMIT = 3

  def contruction
    redirect_to("/construction.html")
  end

  def load_session(user)
    person = Person.find_by_current_and_email(true, user.name)
    uri = session[:requested_uri]
    session[:user_email] = user.name
    # Lookup this persons access level (based on the leadership dir at lds.org)
    access_level = 0
    calling = Calling.find_by_person_id(person.id)
    unless calling == nil
      access_level = calling.access_level
    end
    session[:access_level] = access_level 
    # TODO Hope Hack
    if person.id == 1
      session[:user_name] = "The Hopes"
    else
      session[:user_name] = person.name + " " +  person.family.name
    end
    session[:first_name] = person.name
    session[:user_id] = person.id
    refresh_session


    # record when the last login happened
    user.last_login = Date.today
    user.save

    # Landing page
    # first go to the todo page if they have any outstanding action items
    # then go to any uri that they may have been trying to access
    # if not go to the wardlist
    hasActions = person.open_action_items.size > 0
    if hasActions
        redirect_to(:controller => 'users', :action => 'todo')
    elsif (uri != nil) and (uri =~ /login/i) == nil
        redirect_to(uri)
    else
        redirect_to(:controller => 'families')
    end
  end

  # TODO hope hack
  # I would also like to ensure that this only happens once since it happens 
  # often.
  def getMapping
    @@names ||= Person.find_all_by_current(true, :order=>'name').map do |s|
      if s.family
        if s.family.name == "Hope"
          ["The Hopes", s.id]
        else
          [s.name.split(" ")[0] + " " + s.family.name, s.id]
        end
      else
        [s.name.split(" ")[0], s.id]
      end
    end
  end

  
  def getFamilyMapping
    @families = Family.find_all_by_current(true, :order => 'name').map do |s| 
      [s.name + "," + s.head_of_house_hold, s.id]
    end
  end

protected 
  def authorize
    if session[:user_email] == nil
      flash[:notice] = "Please log in.  Or click on the 'Create a new Account' link to the left"
      session[:requested_uri] = request.request_uri
      redirect_to :controller => 'login', :action=> 'login'
      return
    end
    if (session[:expiration] == nil) or (session[:expiration] < Time.now)  
      reset_session
      session[:requested_uri] = request.request_uri
      flash[:notice] = "User Session Expired.  Please login."
      redirect_to :controller => 'login', :action => 'login'
      return
    end
    # Refresh the activity period
    refresh_session
  end

  def refresh_session
    session[:expiration]  = INACTIVITY_PERIOD.minutes.from_now
  end

  def checkAccess
    # Make the default the most restrictive
    if hasAccess(2)
      true
    else
      deny_access
    end
  end

  def hasAccess(value)
    session[:access_level] >= value 
  end

  def deny_access
    flash[:notice] = "User '#{session[:user_name]}' does not have access to that page"
    if request.env["HTTP_REFERER"] and !request.env["HTTP_REFERER"].include?("login")
      redirect_to :back  
    else
      redirect_to "/todo"  
    end
    return false
  end

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
end
