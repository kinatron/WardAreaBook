class Family < ActiveRecord::Base
  has_many :events, :order => 'date DESC'
  
  ALL = self.find(:all, :order=>'name').map do |s|
    [s.name, s.id]
  end
end
