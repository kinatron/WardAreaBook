class CompanionshipsController < ApplicationController
  # GET /companionships
  # GET /companionships.xml
  def index
    @companionships = Companionship.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @companionships }
    end
  end

  # GET /companionships/1
  # GET /companionships/1.xml
  def show
    @companionship = Companionship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @companionship }
    end
  end

  # GET /companionships/new
  # GET /companionships/new.xml
  def new
    @companionship = Companionship.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @companionship }
    end
  end

  # GET /companionships/1/edit
  def edit
    @companionship = Companionship.find(params[:id])
  end

  # POST /companionships
  # POST /companionships.xml
  def create
    @companionship = Companionship.new(params[:companionship])

    respond_to do |format|
      if @companionship.save
        flash[:notice] = 'Companionship was successfully created.'
        format.html { redirect_to(@companionship) }
        format.xml  { render :xml => @companionship, :status => :created, :location => @companionship }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @companionship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /companionships/1
  # PUT /companionships/1.xml
  def update
    @companionship = Companionship.find(params[:id])

    respond_to do |format|
      if @companionship.update_attributes(params[:companionship])
        flash[:notice] = 'Companionship was successfully updated.'
        format.html { redirect_to(@companionship) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @companionship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /companionships/1
  # DELETE /companionships/1.xml
  def destroy
    @companionship = Companionship.find(params[:id])
    @companionship.destroy

    respond_to do |format|
      format.html { redirect_to(companionships_url) }
      format.xml  { head :ok }
    end
  end
end
