class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update, :activate]  
  skip_before_filter :authorize, :checkAccess
  layout 'login'

  def new
    render
  end

  def activate
    if @user
      @user.verify!
      flash[:notice] = "Thank you for verifying your account. You may now login."
    end
      redirect_to login_url
  end

  def create  
    @user = User.find_by_email(params[:email])  
    if @user  
      @user.deliver_password_reset_instructions!  
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +  
        "Please check your email."  
    else  
      flash[:notice] = "No user was found with that email address"  
      render :action => :new  
    end  
  end  


  def edit  
    render  
  end  

  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "Password successfully updated"  
      #load_session
      redirect_to login_url
    else  
      render :action => :edit  
    end  
  end  

  private  
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
        "If you are having issues try copying and pasting the URL " +  
        "from your email into your browser or restarting the " +  
        "reset password process." 
      # TODO do a redirect to remove the flash notice.
      render "shared/blank"
    end  
  end

end
