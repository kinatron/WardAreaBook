class ActionItemsController < ApplicationController
  in_place_edit_for :action_item, :action
  before_filter :store_return_point, :only =>[:wardActionItems]
  listLimit = 5

  def checkAccess
    if (action_name == 'wardActionItems')
      if hasAccess(2)
        true
      else
        deny_access
      end
    else
      true
    end
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

  def list_closed_action_items 
    condition = params[:conditions]
    @closed_action_items = ActionItem.find_all_by_status("closed", 
                                                         :conditions=>condition,
                                                         :order => 'updated_at DESC')
    render :update do |page|
      page.replace_html('closed-actions', 
                        :partial => "action_items/action_items", 
                        :object => @closed_action_items,
                        :locals => {:checkbox => true,
                                    :editable => true,
                                    # if condition is nil then this is for the ward action
                                    # page and I do want to show the family
                                    :family => (condition == nil),
                                    :ward_representative => true})
    end
  end

# Used in the next two actions  
ACTION_ITEM_OPTIONS = {:checkbox => true,
                       :ward_representative => true,
                       :family => true,
                       :editable => true,
                       :form_action => "save_action"}

  def wardActionItems 
    @actionItemOptions = ACTION_ITEM_OPTIONS
    @open_action_items   = ActionItem.find_all_by_status("open", :order => 'person_id, due_date ASC, updated_at DESC' )
    @person_actions = @open_action_items.group_by { |assignee| assignee.person } 
    

    @closed_action_items = ActionItem.find_all_by_status("closed", 
                                                         :conditions => ['updated_at > ?',1.week.ago], 
                                                         :order => 'updated_at DESC')

    @new_action_item = ActionItem.new
    @names = getMapping
    @families = getFamilyMapping
    @limit = CLOSED_ACTION_LIMIT
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @action_items }
    end
  end

  def save_action
    @actionItemOptions = ACTION_ITEM_OPTIONS
    @action_item = ActionItem.find(params[:id])
    #TODO error handling
    if @action_item.update_attributes(params[:action_item])
      #    @action_item.save
      @open_action_items   = ActionItem.find_all_by_status("open", :order => 'due_date ASC, updated_at DESC' )
      @closed_action_items = ActionItem.find_all_by_status("closed", :order => 'updated_at DESC')
      render :update do |page|
        page.replace_html("open-actions", 
                          :partial => "action_items/action_items",
                          :object => @open_action_items,
                          :locals => @actionItemOptions )
        page.replace_html("closed-actions", 
                          :partial => 'action_items/action_items', 
                          :object => @closed_action_items,
                          :locals => @actionItemOptions )
      end
    else 
      #TODO error handling!!
      render :update do |page|
        page.replace_html("updated-action-list", 
                          :partial => "action_items/action_item")
      end
    end
  end

  # TODO DRY
  def save_personal_action
    @limit = 3
    @action_item = ActionItem.find(params[:id])
    #TODO error handling
    if @action_item.update_attributes(params[:action_item])
      #    @action_item.save
      @person = @action_item.person
      render :update do |page|
        page.replace_html("open-actions", 
                          :partial => "action_items/action_items",
                          :object => @person.open_action_items,
                          :locals => {:checkbox => true,
                            :ward_representative => false,
                            :family => true,
                            :form_action => "save_personal_action",
                            :editable => true} ) 

        page.replace_html("closed-actions", 
                          :partial => "action_items/action_items",
                          :object => @person.closed_action_items,
                         :locals => {:checkbox => true,
                           :editable => true,
                           :family => true,
                           :ward_representative => false,
                           :form_action => "save_personal_action",
                           :conditions => "person_id==#{@person.id}"}) 
      end
    else 
      #TODO error handling!!
      render :update do |page|
        page.replace_html("updated-action-list", 
                          :partial => "action_items/action_item")
      end
    end
  end

  #TODO DRY
  def save_family_action
    @action_item = ActionItem.find(params[:id])
    #TODO error handling
    if @action_item.update_attributes(params[:action_item])
      #    @action_item.save
      @family = @action_item.family
      render :update do |page|
        page.replace_html("open-actions", 
                          :partial => "action_items/action_items",
                          :object => @family.open_action_items,
                          :locals => {:checkbox => true,
                                      :editable => true,
                                      :ward_representative => true})


        page.replace_html("closed-actions", 
                          :partial => "action_items/action_items",
                          :object => @family.closed_action_items,
                          :locals => {:checkbox => true,
                                      :editable => true,
                                      :ward_representative => true})
      end
    else 
      #TODO error handling!!
      render :update do |page|
        page.replace_html("updated-action-list", 
                          :partial => "action_items/action_item")
      end
    end
  end

  def edit_remotely
    @action_item = ActionItem.find(params[:id])
    @names = getMapping
    @families = getFamilyMapping
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html("action_#{@action_item.id}", 
                            :partial => 'edit_action_item',
                            :object => @action_item,
                            :locals => {:peopleList => @names,
                                        :redirect => 'ward',
                                        :familyList => @families})
        end
      }
    end
  end

  # GET /action_items/1/edit
  def edit
    @action_item = ActionItem.find(params[:id])
    @familyList = getFamilyMapping 
    @personList = getMapping 
  end

  # POST /action_items
  # POST /action_items.xml
  def create
    @action_item = ActionItem.new(params[:action_item])
    @action_item.issuer_id = session[:user_id]
    respond_to do |format|
      if @action_item.save
        format.html { redirect_to(:back) }
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
        #flash[:notice] = 'ActionItem was successfully updated.'
        format.html { redirect_back}
        #format.html { redirect_to(family_path(@action_item.family))}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @action_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  #TODO Hack!  There's got to be a more approprate way to do this.
  def remove
    destroy
  end

  # DELETE /action_items/1
  # DELETE /action_items/1.xml
  def destroy
    @action_item = ActionItem.find(params[:id])
    @action_item.destroy
    respond_to do |format|
      format.html { redirect_to(:back) }
      format.xml  { head :ok }
    end
  end
end
