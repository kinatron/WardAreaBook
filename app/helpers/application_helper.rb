# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def getWardRepresentative(id)
    begin
      WardRepresentative.find(id).name
    rescue
      "Error with id " + id.to_s
    end
  end
end
