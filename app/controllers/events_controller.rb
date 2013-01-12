class EventsController < ApplicationController
  layout 'admin'
  cache_sweeper :family_sweeper, :only => [:create_new_family_event, :remove, :update]

# TOOD probably want to make this more restrictive
  def checkAccess
  end


  def all_family_events
    @family = Family.find(params[:id])
    render :update do |page|
      page.replace_html('family-events', 
                        :partial => "events/list_events", 
                        :object => @family.events)
    end
  end

  def edit_remotely
    @event = Event.find(params[:id])
    render :update do |page|
      page.replace_html("event_#{@event.id}", 
                        :partial => "events/event_edit", 
                        :object => @event)
    end
  end

  def update_remotely
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        #flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_back }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /events
  # GET /events.xml
  def index
    if hasAccess(3)
      @events = Event.all

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @events }
      end
    else
      deny_access
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    render :layout => 'WardAreaBook'
  end

  

  def create_new_family_event
    @event = Event.new(params[:event])
    @event.author = session[:user_id]

    respond_to do |format|
      if @event.save
        #Advance the next milestone if: 
        #    the event is a memberMilestone 
        #    user has a teaching record
        #    this event is the current milestone
        if @template.memberMilestones.include?([@event.category,@event.category]) and 
            @event.family.teaching_record and 
            @event.category == @event.family.teaching_record.membership_milestone
          nextMileStone = @template.getNextMileStone(@event.family)
          @event.family.teaching_record.membership_milestone = nextMileStone[0]
          @event.family.teaching_record.save!
        end
        #flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(:controller => 'families', 
                                  :action => 'show', :id => @event.family_id)}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.author = session[:user_id]

    respond_to do |format|
      if @event.save
        #flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        #flash[:notice] = 'Event was successfully updated.'
        format.html { render :action => "show" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  #TODO Hack!  There's got to be a more approprate way to do this.
  def remove
    destroy
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    #flash[:notice] = 'Event successfully deleted.'
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_back }
      format.xml  { head :ok }
    end
  end
end
