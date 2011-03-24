# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

include RedirectBack
class ApplicationController < ActionController::Base
  before_filter :authorize, :checkAccess
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "WardAreaBook"
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Minutes of inactivity before relogin
  INACTIVITY_PERIOD = 60
  CLOSED_ACTION_LIMIT = 3

  def contruction
    redirect_to("/construction.html")
  end

  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  private
  #####################################################################3
  # Authlogic example code
  #
  # Taken form the authlogic example TODO decide what to keep
  # I like to keep session information inside of the session hash
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to login_path
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    #
    # Authlogic code
    #####################################################################3

  def load_session()
    user = current_user
    if user.person == nil
      user.person = Person.find_by_email(user.email)
      user.save!
    end
    person = user.person 
    uri = session[:requested_uri]
    session[:user_email] = user.email
    # Lookup this persons access level (based on the leadership dir at lds.org)
    access_level = 0
    calling = Calling.find_by_person_id(user.person.id)
    unless calling.nil? 
      access_level = calling.access_level
    end
    session[:access_level] = access_level 
    # TODO Hope Hack
    if user.person.id == 1
      session[:user_name] = "The Hopes"
    else
      session[:user_name] = user.person.full_name
    end
    session[:first_name] = user.person.name
    session[:user_id] = user.person.id
    refresh_session


    # Landing page
    # first go to the todo page if they have any outstanding action items
    # then go to any uri that they may have been trying to access
    # if not go to the wardlist
    hasActions = user.person.open_action_items.size > 0
    if hasActions
        redirect_to(:controller => 'users', :action => 'todo')
    elsif (uri != nil) and (uri =~ /login/i) == nil
        redirect_to(uri)
    else
        redirect_to(:controller => 'families')
    end
  end

  # I would also like to ensure that this only happens once since it happens 
  # often.
  # TODO move this into the Person class
  def getMapping
    Person.selectionList
  end

  # move this into the Family class. 
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
      redirect_to login_path
      return
    end
    if (session[:expiration] == nil) or (session[:expiration] < Time.now)  
      reset_session
      session[:requested_uri] = request.request_uri
      flash[:notice] = "User Session Expired.  Please login."
      redirect_to login_path
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

end
