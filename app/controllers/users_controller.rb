class UsersController < ApplicationController
  before_filter :store_return_point, :only =>[:todo]
  layout 'login'

  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all, :order => :name)
    render :layout => 'admin'
  end

  def todo
    @limit = 3
    if (params[:id])
      @person = Person.find(params[:id])
    else 
      @person = Person.find(session[:user_id])
    end
    @openActionItems   = @person.open_action_items
    @closedActionItems = @person.closed_action_items
    @new_action_item = ActionItem.new
    @names = getMapping
    @families = getFamilyMapping
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
    @user = User.new(params[:user])
    # TODO Make access level an attribute of the person class
    # and update priv's according to the leadership page on the 
    # church website.
    @user.access_level = 2
    if @user.save
      load_session(@user)
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
        flash[:notice] = "User #{@user.name} was successfully updated."
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
  
protected

# TODO you've given access for anyone to create modify or delete users.

  def authorize
    unless params[:action] == 'new' || params[:action] == 'create' || params[:action] == 'todo'
      super
    end
  end

  def checkAccess
    unless action_name == "new" or action_name == "create" or action_name == "todo"  
      if hasAccess(3)
        true
      else
        deny_access
      end
    end
  end
end
