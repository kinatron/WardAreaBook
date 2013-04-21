class ApplicationController < ActionController::Base
  before_filter :authorize, :checkAccess

  protect_from_forgery

  INACTIVITY_PERIOD = 60
  CLOSED_ACTION_LIMIT = 3
  layout "WardAreaBook"

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
    session[:return_to] = request.fullpath
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def load_session()
    user = current_user
    user.logged_in_now = true
    if user.person == nil
      user.person = Person.find_by_email(user.email)
      user.save!
    end
    person = user.person 
    uri = session[:requested_uri]
    session[:user_email] = user.email
    session[:access_level] = person.access_level
    session[:user_name] = person.full_name
    session[:first_name] = person.name
    session[:user_id] = person.id
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


protected 
  def authorize
    if session[:user_email] == nil
      flash[:notice] = "Please log in.  Or click on the 'Create a new Account' link to the left"
      session[:requested_uri] = request.fullpath
      redirect_to login_path
      return
    end
    if (session[:expiration] == nil) or (session[:expiration] < Time.now)  
      reset_session
      session[:requested_uri] = request.fullpath
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
    # TODO: I'm bumping this from 2 to 3 per issue #40;
    # need to check if that's correct
    if hasAccess(3)
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
