class Person < ActiveRecord::Base
  belongs_to :family
  # TODO this is a very costly operation.  Find out how to cache this.
  ALL = self.find(:all, :order=>'name').map do |s|
    if s.name == "Elder and Sister"
      [s.name + " " + s.family.name, s.id]
    else
      [s.name.split(" ")[0] + " " + s.family.name, s.id]
    end
  end
  
end
