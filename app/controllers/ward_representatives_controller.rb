class WardRepresentativesController < ApplicationController
  # GET /ward_representatives
  # GET /ward_representatives.xml
  def index
    @ward_representatives = WardRepresentative.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ward_representatives }
    end
  end

  # GET /ward_representatives/1
  # GET /ward_representatives/1.xml
  def show
    @ward_representative = WardRepresentative.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ward_representative }
    end
  end

  # GET /ward_representatives/new
  # GET /ward_representatives/new.xml
  def new
    @ward_representative = WardRepresentative.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ward_representative }
    end
  end

  # GET /ward_representatives/1/edit
  def edit
    @ward_representative = WardRepresentative.find(params[:id])
  end

  # POST /ward_representatives
  # POST /ward_representatives.xml
  def create
    @ward_representative = WardRepresentative.new(params[:ward_representative])

    respond_to do |format|
      if @ward_representative.save
        flash[:notice] = 'WardRepresentative was successfully created.'
        format.html { redirect_to(@ward_representative) }
        format.xml  { render :xml => @ward_representative, :status => :created, :location => @ward_representative }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ward_representative.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ward_representatives/1
  # PUT /ward_representatives/1.xml
  def update
    @ward_representative = WardRepresentative.find(params[:id])

    respond_to do |format|
      if @ward_representative.update_attributes(params[:ward_representative])
        flash[:notice] = 'WardRepresentative was successfully updated.'
        format.html { redirect_to(@ward_representative) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ward_representative.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ward_representatives/1
  # DELETE /ward_representatives/1.xml
  def destroy
    @ward_representative = WardRepresentative.find(params[:id])
    @ward_representative.destroy

    respond_to do |format|
      format.html { redirect_to(ward_representatives_url) }
      format.xml  { head :ok }
    end
  end
end
