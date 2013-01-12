class FamiliesController < ApplicationController
  caches_action :index, :layout => false
  caches_action :members, :layout => false
  #TODO for some reason the sweeper is not getting called when I update 
  #the family records.  So I instead I'm explicitly updating this.
  #the sweeper is working for the events_controller....
  cache_sweeper :family_sweeper, :only => [:update, :edit]
  in_place_edit_for :action_item, :action

  @hasFullAccess = false

  # override the application accessLevel method
  # TODO refactor this method
  def checkAccess
    @hasFullAccess = hasAccess(2)
    # Everybody has access to these methods
    if hasAccess(2) or 
       action_name == 'members' or 
       action_name == 'show' or 
       action_name == 'edit_status' or 
       (action_name == 'edit' and (Family.find(params[:id]).hasHomeTeacher(session[:user_id]) or @family.hasVisitingTeacher(session[:user_id]))) or 
       (action_name == 'update' and (Family.find(params[:id]).hasHomeTeacher(session[:user_id]) or @family.hasVisitingTeacher(session[:user_id])))
      true
    elsif
      action_name == 'index' and not hasAccess(2)
      redirect_to(:action => 'members')
    else
      deny_access
    end
  end

  # GET /families
  # GET /families.xml
  def index
    @families = Family.find_all_by_member_and_current(true,true, :order => :name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @families }
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

  def new_comment
    @fam = Family.find(params[:id])
    @comment = Comment.create(:family_id => @fam.id)
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html("new comment", :partial => "new_comment", :object => @comment)
        end
      }
    end

  end

  def investigators
    @families = Family.find_all_by_member_and_current(false, true, :order => :name)
    respond_to do |format|
      format.html # investigators.html.erb
      format.xml  { render :xml => @families }
    end
  end

  def edit_status
    @edit_status = true
    show
  end

  def listArchived
    @families = Family.find_all_by_member_and_current(false, false, :order => :name)
    render :update do |page|
      page.replace_html("archived-families",
                   :partial => "droppedFamilies",
                   :object => @families)
    end
  end

  def mergeRecords
    @family = Family.find(params[:family])
    if @family.member
      redirect_to :back 
    else
      @familyList = Family.find_all_by_member_and_current(true,true)
      respond_to do |format|
        format.html # investigators.html.erb
        format.xml  { render :xml => @families }
      end
    end
  end

  def merge_the_record
    @family = Family.find(params[:family])
    @memberRecord = Family.find(params[:family_to_merge_with])
    @family.mergeTo(@memberRecord)
    respond_to do |format|
      format.html { redirect_to(@memberRecord) }
    end
  end


  # GET /families/1
  # GET /families/1.xml
  def show
    @family = Family.find(params[:id])
    @action_item = ActionItem.new
    @action_item.family_id = @family.id

    @names = Person.selectionList
    @families = Family.get_families

    @familyName = @family.name + "," + @family.head_of_house_hold;
    @fellowShippers = Person.selectionList

    @event =  Event.new
    @event.family_id = @family.id

    @limit = CLOSED_ACTION_LIMIT

    if @hasFullAccess or @family.hasHomeTeacher(session[:user_id]) or @family.hasVisitingTeacher(session[:user_id])
      render "show"
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
    begin
      if params[:family][:status] != @family.status
        @family.events.create(:date => Date.today, 
                              :person_id => session[:user_id],
                              :author => session[:user_id],
                              :comment => "Changed status from #{@family.status} 
                                           to #{params[:family][:status]}")
      end
    rescue
      logger.info("Caught an Exception")
    end
    respond_to do |format|
      if @family.update_attributes(params[:family])
        expire_action :action => "index"
        expire_action :action => "show", :id => @family
        #flash[:notice] = 'Family was successfully updated.'
        format.js {
          render :update do |page|
          page.replace_html("family_status", 
                            :partial => "family_status", 
                            :object => @family,
                            :locals => {:update => nil})
          end
        }
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

  def archive 
    @family = Family.find(params[:id])
    if params[:restore] == 'true'
      @family.current = true
      if @family.teaching_record 
        @family.teaching_record.current = true
        @family.teaching_record.save
      end
    else
      @family.current = false
      if @family.teaching_record 
        @family.teaching_record.current = false
        @family.teaching_record.save
      end
    end
    @family.save
    respond_to do |format|
      format.html { redirect_to(:action => 'investigators') }
      format.xml  { head :ok }
    end
  end
end
