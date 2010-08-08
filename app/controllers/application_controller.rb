# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :checkAccess, :except => :login
  include RedirectBack
  helper :all # include all helpers, all the time

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "WardAreaBook"

  # Minutes of inactivity before relogin
  INACTIVITY_PERIOD = 60

  def load_session(user)
    person = Person.find_by_email(user.name)
    uri = session[:requested_uri]
    session[:user_email] = user.name
    session[:access_level] = user.access_level
    session[:user_name] = person.name + " " +  person.family.name
    session[:user_id] = person.id
    refresh_session
    redirect_to(uri || {:controller => 'families'})
  end

  def getMapping
    @@names ||= Person.find(:all, :order=>'name').map do |s|
      if s.name == "Elder and Sister"
        ["The Hopes", s.id]
      else
        if s.family
          [s.name.split(" ")[0] + " " + s.family.name, s.id]
        else
          [s.name.split(" ")[0], s.id]
        end
      end
    end
  end

  
  def getFamilyMapping
    @families = Family.find(:all, :order => :member, 
                            :conditions => "current=='t' or member=='f'").map do |s|
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
    if session[:access_level] < 3
      deny_access
    end
  end

  def deny_access
      flash[:notice] = "User '#{session[:user_name]}' does not have access to that page"
      if request.env["HTTP_REFERER"]  
        (redirect_to :back)  
      else
        #redirect_to session[:home_url]
        #TODO this should go back to the page they just came from
        redirect_to :controller=>  :families, :action => :index
      end
      return false
  end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
