class WardRepresentative < ActiveRecord::Base
  ALL = self.find(:all, :order=>'name').map do |s|
    [s.name, s.id]
  end

end
