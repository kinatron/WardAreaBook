class CommentsController < ApplicationController

# TOOD probably want to make this more restrictive
  def checkAccess
  end
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  def remove
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html("comments", :partial => "families/comment", 
                                        :collection => @comment.family.comments)
        end
      }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new(:family_id => params[:id], :person_id => session[:user_id])

    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html("new comment", :partial => 'new_comment')
        end
      }
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  def edit_remotely
    @comment = Comment.find(params[:id])
    @comment.person_id = session[:user_id]
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html("comment_#{@comment.id}", :partial => 'edit_comment')
        end
      }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
    respond_to do |format|
        format.html 
        format.xml  
    end
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @family = @comment.family

    respond_to do |format|
      if @comment.save
        format.js {
          render :update do |page|
            page.replace_html("comments", :partial => "families/comment", 
                                          :collection => @comment.family.comments)
            page.replace_html("new comment", :partial => "families/submit_button")
          end
        }
        format.html { redirect_to(@comment) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
  def familyComments
    begin
    @comment = Comment.find(params[:id])

    render :update do |page|
      page.replace_html("comments", :partial => "families/comment", 
                        :collection => @comment.family.comments)
    end
    rescue
      @family = Family.find(params[:family_id])
      render :update do |page|
        page.replace_html("new comment", :partial => "families/submit_button")
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.js {
          render :update do |page|
            page.replace_html("comments", :partial => "families/comment", 
                                          :collection => @comment.family.comments)
          end
        }
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html("comments", :partial => "families/comment", 
                                        :collection => @comment.family.comments)
        end
      }
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
