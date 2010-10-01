class NameMappingsController < ApplicationController
  # GET /name_mappings
  # GET /name_mappings.xml
  def index
    @name_mappings = NameMapping.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @name_mappings }
    end
  end

  # GET /name_mappings/1
  # GET /name_mappings/1.xml
  def show
    @name_mapping = NameMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @name_mapping }
    end
  end

  # GET /name_mappings/new
  # GET /name_mappings/new.xml
  def new
    @name_mapping = NameMapping.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @name_mapping }
    end
  end

  # GET /name_mappings/1/edit
  def edit
    @name_mapping = NameMapping.find(params[:id])
  end

  # POST /name_mappings
  # POST /name_mappings.xml
  def create
    @name_mapping = NameMapping.new(params[:name_mapping])

    respond_to do |format|
      if @name_mapping.save
        flash[:notice] = 'NameMapping was successfully created.'
        format.html { redirect_to(@name_mapping) }
        format.xml  { render :xml => @name_mapping, :status => :created, :location => @name_mapping }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @name_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /name_mappings/1
  # PUT /name_mappings/1.xml
  def update
    @name_mapping = NameMapping.find(params[:id])

    respond_to do |format|
      if @name_mapping.update_attributes(params[:name_mapping])
        flash[:notice] = 'NameMapping was successfully updated.'
        format.html { redirect_to(@name_mapping) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @name_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /name_mappings/1
  # DELETE /name_mappings/1.xml
  def destroy
    @name_mapping = NameMapping.find(params[:id])
    @name_mapping.destroy

    respond_to do |format|
      format.html { redirect_to(name_mappings_url) }
      format.xml  { head :ok }
    end
  end
end
