# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def getWardRepresentative(id)
    if (WardRepresentative.find(id) == nil || id == nil || id == "")
      ""
    else 
      WardRepresentative.find(id).name
    end
  end
end
