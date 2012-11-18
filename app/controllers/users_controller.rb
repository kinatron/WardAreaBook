class UsersController < ApplicationController
  skip_before_filter :authorize, :only => [:new, :create]
  skip_before_filter :checkAccess, :only => [:new, :create, :todo]
  layout 'login'

  # GET /users
  # GET /users.xml
  def index
    @users = User.order('email')
    render :layout => 'admin'
  end

  def todo
    @limit = 3
    if (params[:id])
      @person = Person.find(params[:id])
      unless hasAccess(2)
        redirect_to families_path
        return
      end
    else 
      @person = Person.find(session[:user_id])
    end
    @openActionItems   = @person.open_action_items
    @closedActionItems = @person.closed_action_items
    @new_action_item = ActionItem.new
    @names = Person.selectionList
    @families = Family.get_families
    render :layout => 'WardAreaBook'
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new

    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create

    # If there is another user logged on at the time. Delete their session
    @user_session = UserSession.find  
    if @user_session
      @user_session.destroy 
      reset_session
    end

    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = "Thanks for signing up, we've delivered an email to you with instructions on how to complete your registration!"
      @user.deliver_verification_instructions!

      render "shared/blank" 

    else
       render :action => "new" 
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "User #{@user.email} was successfully updated."
        format.html { redirect_to(:action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
