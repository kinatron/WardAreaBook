class Family < ActiveRecord::Base
  has_many :people, :events, :order => 'date DESC'
  has_one :teaching_record
  
#  ALL = self.find(:all, :order=>'name').map do |s|
#    [s.name, s.id]
#  end
end
