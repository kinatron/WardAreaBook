class Family < ActiveRecord::Base
  has_many :events, :order => 'date DESC'
  has_many :people 
  has_many :teaching_routes  # really it only has two 
  has_one :teaching_record
  validates_presence_of :name, :head_of_house_hold
  
  ALL = self.find_all_by_member_and_current(true,true, :order=>'name').map do |s|
    begin
    [s.name + ", " + s.head_of_house_hold, s.id]
    rescue
    end
  end

  def hasHomeTeacher(person_id)
    self.teaching_routes.each do |route|
      return true if route.person_id == person_id 
    end
    return false
  rescue
    return false
  end

  def mergeTo(familyRecord)
    begin
      # Copy over the events
      self.events.each do |event|
        event.family_id = familyRecord.id
        event.save!
      end

      #copy over any teaching records
      if self.teaching_record
        self.teaching_record.family_id = familyRecord.id
        self.teaching_record.save!
      end

      # Append any append any infomation to the new record
      if self.information
        # TODO there's got to be a better way of doing this....
        if familyRecord.information
          familyRecord.information += "<br> " + self.information
        else
          familyRecord.information =  self.information
        end
        familyRecord.save!
      end

      # finally delete this record
      self.delete
    end
  end


end
