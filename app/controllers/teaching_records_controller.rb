class TeachingRecordsController < ApplicationController
  cache_sweeper :family_sweeper, :only => [:update]

  def checkAccess
    #only the ward council has access
    if hasAccess(2)
      true
    else
      deny_access
    end
  end

  # GET /teaching_records
  # GET /teaching_records.xml
  def index
    @records = TeachingRecord.find_all_by_current(true, :order => "organization DESC").group_by {|record| record.organization} 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teaching_records }
    end
  end

  def listArchived
    @teaching_records = TeachingRecord.find_all_by_current(false)
    render :update do |page|
      page.replace_html("archived-records",
                        :partial => "listArchived")
    end
  end

  # GET /teaching_records/1
  # GET /teaching_records/1.xml
  def show
    @teaching_record = TeachingRecord.find(params[:id])
    @family = Family.find(@teaching_record.family_id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teaching_record }
    end
  end

  # GET /teaching_records/new
  # GET /teaching_records/new.xml
  def new
    @lessons = [0,0,0,0,0,0]
    @teaching_record = TeachingRecord.new
    @families = getFamilyMapping
    @fellowShippers = getMapping

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teaching_record }
    end
  end

  # GET /teaching_records/1/edit
  def edit
    @teaching_record = TeachingRecord.find(params[:id])
    @family = Family.find(@teaching_record.family_id)
    if @family
      @familyName = @family.name + "," + @family.head_of_house_hold;
    else
      @familyName = ""
    end

    @families = getFamilyMapping
    @fellowShippers = getMapping
  end

  # POST /teaching_records
  # POST /teaching_records.xml
  def create
    @teaching_record = TeachingRecord.new(params[:teaching_record])
    @teaching_record.current = true
    if @teaching_record.family.member and @teaching_record.membership_milestone == "Baptized"
      @teaching_record.membership_milestone = "Interview with the Bishop"
    end

    respond_to do |format|
      if @teaching_record.save
        #flash[:notice] = 'TeachingRecord was successfully created.'
        format.html { redirect_to(:action => "index") }
        format.xml  { render :xml => @teaching_record, :status => :created, :location => @teaching_record }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teaching_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teaching_records/1
  # PUT /teaching_records/1.xml
  def update
    @teaching_record = TeachingRecord.find(params[:id])

    respond_to do |format|
      if @teaching_record.update_attributes(params[:teaching_record])
        #flash[:notice] = 'TeachingRecord was successfully updated.'
        format.html { redirect_to(teaching_records_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teaching_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teaching_records/1
  # DELETE /teaching_records/1.xml
  def destroy
    @teaching_record = TeachingRecord.find(params[:id])
    @teaching_record.destroy

    respond_to do |format|
      format.html { redirect_to(teaching_records_url) }
      format.xml  { head :ok }
    end
  end

  def archive
    @teaching_record = TeachingRecord.find(params[:id])
    if params[:restore] == 'true'
      @teaching_record.current = true
      # TODO I think this kind of logic belongs in the model not a controller.
                                    # can't drop members
      if @teaching_record.family and not @teaching_record.family.member
        @teaching_record.family.current = true
        @teaching_record.family.save
      end
    else
      @teaching_record.current = false
      if @teaching_record.family and not @teaching_record.family.member
        @teaching_record.family.current = false
        @teaching_record.family.save
      end
    end
    respond_to do |format|
      if @teaching_record.save
        format.html { redirect_to(teaching_records_url) }
      else
        format.html { redirect_to(families_records_url) }
      end
    end
  end
end
