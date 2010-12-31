class ActionItemsController < ApplicationController
  in_place_edit_for :action_item, :action
  listLimit = 5

  def authorize
  end

  def checkAccess
  end

  # GET /action_items
  # GET /action_items.xml
  def index
    @action_items = ActionItem.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @action_items }
    end
  end

  # GET /action_items/1
  # GET /action_items/1.xml
  def show
    @action_item = ActionItem.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @action_item }
    end
  end

  # GET /action_items/new
  # GET /action_items/new.xml
  def new
    @action_item = ActionItem.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @action_item }
    end
  end

  def new_family_action_item
    @names = getMapping
    @action_item = ActionItem.new
    @action_item.family_id = params[:family_id]
    render :update do |page|
      page.replace_html('new-action', :partial => "new_action_item_for_family")
    end
  end

  def all_closed_family_action_items 
    @family = Family.find(params[:id])
    render :update do |page|
      page.replace_html('closed-family-actions', 
                        :partial => "action_items/action_items", 
                        :object => @family.closed_action_items)
    end
  end

  def save_family_action
    @action_item = ActionItem.find(params[:id])
    #TODO Globals
    listLimit = 3
    #TODO error handling
    if @action_item.update_attributes(params[:action_item])
      #    @action_item.save
      @family = @action_item.family
      render :update do |page|
        page.replace_html("open-family-actions", 
                          :partial => "action_items/action_items",
                          :object => @family.open_action_items)

        page.replace_html("closed-family-actions", 
                          :partial => "action_items/action_items",
                          :object => @family.closed_action_items[0..listLimit-1],
                          :locals => {:option_for_more => true})
      end
    else 
      #TODO error handling!!
      render :update do |page|
        page.replace_html("updated-action-list", 
                          :partial => "action_items/action_item")
      end
    end
  end

  # GET /action_items/1/edit
  def edit
    @action_item = ActionItem.find(params[:id])
  end

  # POST /action_items
  # POST /action_items.xml
  def create
    @action_item = ActionItem.new(params[:action_item])
    respond_to do |format|
      if @action_item.save
        if params[:redirect] == 'family'
          format.html { redirect_to(@action_item.family) }
        else
          flash[:notice] = 'ActionItem was successfully created.'
          format.html { redirect_to(@action_item) }
          format.xml  { render :xml => @action_item, :status => :created, :location => @action_item }
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @action_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /action_items/1
  # PUT /action_items/1.xml
  def update
    @action_item = ActionItem.find(params[:id])
    respond_to do |format|
      if @action_item.update_attributes(params[:action_item])
        flash[:notice] = 'ActionItem was successfully updated.'
        format.html { redirect_to(@action_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @action_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /action_items/1
  # DELETE /action_items/1.xml
  def destroy
    @action_item = ActionItem.find(params[:id])
    @action_item.destroy
    respond_to do |format|
      format.html { redirect_to(action_items_url) }
      format.xml  { head :ok }
    end
  end
end
