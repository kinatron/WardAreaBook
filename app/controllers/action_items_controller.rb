class ActionItemsController < ApplicationController
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

  def wardActionItems 
    @open_action_items   = ActionItem.find_all_by_status("open", :order => 'person_id, due_date ASC, updated_at DESC' )
    @person_actions = @open_action_items.group_by { |assignee| assignee.person } 
    

    @closed_action_items = ActionItem.find_all_by_status("closed", 
                                                         :conditions => ['updated_at > ?',1.week.ago], 
                                                         :order => 'updated_at DESC')

    @new_action_item = ActionItem.new
    @names = Person.selectionList
    @families = Family.get_families
    @limit = CLOSED_ACTION_LIMIT
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @action_items }
    end
  end

  # POST /action_items
  # POST /action_items.xml
  def create
    # TODO We need some access check on this
    @action_item = ActionItem.new(params[:action_item])
    @action_item.issuer = Person.find(session[:user_id])
    @action_item.status = "open"
    @action_item.save

    if params[:redirect] == "ward"
      redirect_to action_items_wardActionItems_path
    else
      redirect_to @action_item.family
    end
  end

  # PUT /action_items/1
  # PUT /action_items/1.xml
  def update
    # TODO We need some access check on this
    @action_item = ActionItem.find(params[:id])
    @action_item.update_attributes(params[:action_item])
    if params[:redirect] == "ward"
      redirect_to action_items_wardActionItems_path
    else
      redirect_to @action_item.family
    end
  end

  # DELETE /action_items/1
  # DELETE /action_items/1.xml
  def destroy
    # TODO We need some access check on this
    @action_item = ActionItem.find(params[:id])
    family = @action_item.family
    @action_item.destroy

    if params[:redirect] == "ward"
      redirect_to action_items_wardActionItems_path
    else
      redirect_to family
    end
  end
end
