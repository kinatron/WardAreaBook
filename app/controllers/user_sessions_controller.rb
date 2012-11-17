class UserSessionsController < ApplicationController
  skip_before_filter :authorize, :checkAccess
  layout "login"

  def new
    @user_session = UserSession.new
  end

  def create  
    @user_session = UserSession.new(params[:user_session])  
    if @user_session.save  
      @user_session.user.logged_in_now = true
      @user_session.user.failed_login_count = 0
      load_session
    else  
      render :action => 'new'  
    end  
  end 

  def destroy  
    @user_session = UserSession.find  
    if defined?(@user_session)
      @user_session.user.logged_in_now = false
      @user_session.destroy  
    end
    name = session[:user_name]
    reset_session
    flash[:notice] = name, " successfully logged out."
    redirect_to login_url  
  end  

end
