class CommentsController < ApplicationController

# TOOD probably want to make this more restrictive
  def checkAccess
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    if hasAccess(2) || (!@comment.person.nil? && @comment.person.id == session[:user_id])
      @comment.text = params[:text]
      @comment.save
    end

    redirect_to(@comment.family)
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    comment = Comment.find(params[:id])
    family = comment.family

    if hasAccess(2) || (!comment.person.nil? && comment.person.id == session[:user_id])
      comment.destroy
    end

    redirect_to(family)
  end
end
