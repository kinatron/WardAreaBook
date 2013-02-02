class StaticPagesController < ApplicationController
  skip_before_filter :authorize, :checkAccess, :only => :faq

  def faq
    layout = session[:user_name] ? "WardAreaBook" : "login"
    render 'faq', :layout => layout
  end

end
