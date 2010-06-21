# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => :login
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "WardAreaBook"

  def load_session(user)
    session[:user_email] = user.name
    person = Person.find_by_email(user.name)
    session[:user_name] = person.name + " " +  person.family.name
    session[:user_id] = person.id
    redirect_to(:controller => 'families')
  end

  def load_session_roster(user)
    committee_member = CommitteeMember.find_by_email(user.name)
    session[:user_id] = user.name
    session[:user_name] = committee_member.name.match(/\w*/)[0]
    logger.debug(user)
    logger.debug(user.accessLevel)
    session[:edit_actions] = committee_member.access_level
    session[:admin_access] = committee_member.access_level
    session[:read_access] = committee_member.read_level
    session[:cm_id] = committee_member.id

    session[:home_url] = "/report/member_actions/#{committee_member.id}"
    refresh_session

    # TODO are you sure you want to do this?   What about the page they were originally 
    # wanting?  Revisit
    redirect_to(:controller => 'report', :action => "member_actions", :id => committee_member.id) 
  end

protected 
  def authorize
    unless User.find_by_name(session[:user_email])
      flash[:notice] = "Please log in "
      redirect_to :controller => 'login', :action=> 'login'
    end
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
