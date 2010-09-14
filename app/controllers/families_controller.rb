class FamiliesController < ApplicationController
  before_filter :store_return_point, :only => [:show]
  caches_action :index
  #TODO for some reason the sweeper is not getting called when I update 
  #the family records.  So I instead I'm explicitly updating this.
  #the sweeper is working for the events_controller....
  cache_sweeper :family_sweeper, :only => [:update, :edit]

  @hasFullAccess = false

  # override the application accessLevel method
  def checkAccess
    # Everybody has access to these methods
    if hasAccess(2)
      @hasFullAccess = true
    else 
      @hasFullAccess = false
    end
  end



  # GET /families
  # GET /families.xml
  def index
    @families = Family.find_all_by_member_and_current(true,true, :order => :name)

    if @hasFullAccess
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @families }
      end
    else
      render :action => "members"
    end
  end

  # This is a limited access list
  def members
    @families = Family.find_all_by_member_and_current(true,true, :order => :name)
    respond_to do |format|
      format.html # investigators.html.erb
      format.xml  { render :xml => @families }
    end
  end

  def investigators
    if @hasFullAccess
      @families = Family.find_all_by_member(false, :order => :name)
      respond_to do |format|
        format.html # investigators.html.erb
        format.xml  { render :xml => @families }
      end
    else
      flash[:notice] = 'User does not have access to this page.'
      redirect_to(:action => 'index')
    end
  end

  def mergeRecords
    @family = Family.find(params[:family])
    if @hasFullAccess
      @families = Family.find(params[:family_merge])
      respond_to do |format|
        format.html # investigators.html.erb
        format.xml  { render :xml => @families }
      end
    else
      flash[:notice] = 'User does not have access to this page.'
      redirect_to(:action => 'index')
    end
  end

  # GET /families/1
  # GET /families/1.xml
  def show
    @family = Family.find(params[:id])

    @familyName = @family.name + "," + @family.head_of_house_hold;
    @families = getFamilyMapping
    @fellowShippers = getMapping

    if @hasFullAccess
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @family }
      end
    else
      render "show2"
    end
  end

  # GET /families/new
  # GET /families/new.xml
  def new
    @family = Family.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @family }
    end
  end

  # GET /families/1/edit
  def edit
    @family = Family.find(params[:id])
  end

  # POST /families
  # POST /families.xml
  def create
    @family = Family.new(params[:family])

    respond_to do |format|
      if @family.save
        flash[:notice] = 'Family was successfully created.'
        format.html { redirect_to(@family) }
        format.xml  { render :xml => @family, :status => :created, :location => @family }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /families/1
  # PUT /families/1.xml
  def update
    @family = Family.find(params[:id])

    respond_to do |format|
      if @family.update_attributes(params[:family])
        expire_action :action => "index"
        expire_action :action => "show", :id => @family
        #flash[:notice] = 'Family was successfully updated.'
        format.html { redirect_to(@family) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /families/1
  # DELETE /families/1.xml
  def destroy
    @family = Family.find(params[:id])
    @family.destroy

    respond_to do |format|
      format.html { redirect_to(:action => 'investigators') }
      format.xml  { head :ok }
    end
  end

end
