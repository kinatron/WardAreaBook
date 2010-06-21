class LoginController < ApplicationController

  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        load_session(user)
      else 
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end

  def logout
    name = session[:user_name]
    reset_session
    flash[:notice] = name, " successfully logged out."
    redirect_to :controller => 'login'
  end

  def index
  end

end
