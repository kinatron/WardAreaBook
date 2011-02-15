class LoginController < ApplicationController

  def checkAccess

    #      flash.now[:notice] = "This email address is not found in the ward database<br> 
    #        Please either add this email address to your personal account at LDS.org <br>
    #        or contact #{Person.find(RootAdmin.find(:first).person_id).full_name} to add it
    #        manually"
  end


  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        load_session(user)
      else 
        if User.find_by_name(params[:name].downcase)
          flash.now[:notice] = "Invalid user/password combination"
        else
          flash.now[:notice] = 
            "This email address is not found in the ward database<br> 
             You may need to create an account by clicking on the <br>
             'Create new Account' link to the left"
        end
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
