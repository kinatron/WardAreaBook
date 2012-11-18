class Family < ActiveRecord::Base
  has_many :events, :order => 'date DESC, updated_at DESC', :dependent => :destroy
  has_many :people 
  has_many :comments 
  has_many :teaching_routes  # really it only has two 
  has_many :action_items, :order => 'due_date DESC', :dependent => :destroy
  has_many :open_action_items, :class_name => "ActionItem",
                               :conditions => "status == 'open'",
                               :order => 'due_date ASC, updated_at DESC'
  has_many :closed_action_items, :class_name => "ActionItem",
                                 :conditions => "status == 'closed'",
                                 :order => 'updated_at DESC'
  has_one :teaching_record
  validates_presence_of :name, :head_of_house_hold

  ALL = self.find_all_by_member_and_current(true,true).order('name').map do |s|
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

  def lastVisit
    self.events.where("category != 'Attempt' and 
                            category != 'Other' and 
                            category is not NULL").first
  end

  def mergeTo(familyRecord)
    #TODO append action items
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


  def self.visitedWithinTheLastMonths(monthsAgo)
    targetDate = Date.today.months_ago(monthsAgo).at_beginning_of_month
    events = Event.where("(category != 'Attempt' and category != 'Other' and category is not NULL) and date >=?", targetDate)

    events.delete_if { |x| x.family.current==false or 
                           x.family.status=='moved' or x.family.member == false}
    families = events.group_by { |family| family.family_id}
    return families
  end

  def full_name
    "#{self.head_of_house_hold} #{self.name}"
  end

  def self.get_families
    @families = Family.find_all_by_current(true).order('name').map do |s| 
      [s.name + "," + s.head_of_house_hold, s.id]
    end
  end

end
