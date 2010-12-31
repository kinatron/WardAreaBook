class EventsController < ApplicationController
  layout 'admin'
  cache_sweeper :family_sweeper, :only => [:create_new_family_event, :remove, :update]

# TOOD probably want to make this more restrictive
  def checkAccess
  end


  def all_family_events
    @family = Family.find(params[:id])
    render :update do |page|
      page.replace_html('family-events', :partial => "events/list_events", :object => @family.events)
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

  def test_me
    @names = getMapping
    @event = Event.new
    @event.family_id = 51
    @family = Family.find(@event.family_id)
    respond_to do |format|
      format.html # new.html.erb
      #format.xml  { render :xml => @event }
    end
  end

  def new_family_event
    @names = getMapping
    @event = Event.new
    @event.family_id = params[:family_id]
    @family = Family.find(@event.family_id)
    render :update do |page|
      page.replace_html('new-action', :partial => "new_event")
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
  end

  def create_new_family_event
    @event = Event.new(params[:event])
    if (@event.family.teaching_record) and (@event.category =~ /lesson\d/i)
      lessonNum = @event.category.match(/\d/)[0]
      unless @event.family.teaching_record.lessons_taught.include? lessonNum
        if @event.family.teaching_record.lessons_taught.empty? 
          @event.family.teaching_record.lessons_taught = lessonNum
        else
          @event.family.teaching_record.lessons_taught << "," + lessonNum
        end
        @event.family.teaching_record.save
      end
    end

    @event.author = session[:user_id]
    respond_to do |format|
      if @event.save
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
        format.html { redirect_back }
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
