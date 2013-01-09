class CallingsController < ApplicationController
  layout 'admin'

  def checkAccess
    if hasAccess(3)
      true
    else
      deny_access
    end
  end

  def updateAccessLevels
    # because "unchecked checkbox values are not sent I'm going to update everything
    # (except admin level access) to 0 access and then update according to the post
    Calling.update_all("access_level = 0", "access_level < 3")
    callings = params[:accessLevels] || ""
    callings.each do |calling, access_level|
      cal = Calling.find_by_job(calling)
      # don't update admins since they already have access
      if cal.access_level < 3
        cal.access_level = access_level
        cal.save!
      end
    end
    redirect_to(callings_url)
  end

  # GET /callings
  # GET /callings.xml
  def index
    @callings = Calling.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @callings }
    end
  end

  # GET /callings/1
  # GET /callings/1.xml
  def show
    @calling = Calling.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calling }
    end
  end

  # GET /callings/new
  # GET /callings/new.xml
  def new
    @calling = Calling.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @calling }
    end
  end

  # GET /callings/1/edit
  def edit
    @calling = Calling.find(params[:id])
  end

  # POST /callings
  # POST /callings.xml
  def create
    @calling = Calling.new(params[:calling])

    respond_to do |format|
      if @calling.save
        flash[:notice] = 'Calling was successfully created.'
        format.html { redirect_to(@calling) }
        format.xml  { render :xml => @calling, :status => :created, :location => @calling }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @calling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /callings/1
  # PUT /callings/1.xml
  def update
    @calling = Calling.find(params[:id])

    respond_to do |format|
      if @calling.update_attributes(params[:calling])
        flash[:notice] = 'Calling was successfully updated.'
        format.html { redirect_to(@calling) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @calling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /callings/1
  # DELETE /callings/1.xml
  def destroy
    @calling = Calling.find(params[:id])
    @calling.destroy

    respond_to do |format|
      format.html { redirect_to(callings_url) }
      format.xml  { head :ok }
    end
  end
end
