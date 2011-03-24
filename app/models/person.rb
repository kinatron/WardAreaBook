class Person < ActiveRecord::Base
  belongs_to :family
  has_many :teachingRoutes 
  has_many :action_items 
  has_many :events
  has_many :open_action_items, :class_name => "ActionItem",
                               :conditions => "status == 'open'",
                               :order => 'due_date ASC, updated_at DESC'
  has_many :closed_action_items, :class_name => "ActionItem",
                                 :conditions => "status == 'closed'",
                                 :order => 'updated_at DESC'

  def full_name
    if family.name == "Hope"
      "The Hopes"
    elsif family.name == "Elders"
      "The Elders"
    elsif Calling.find_by_job("Bishop").person_id == id
      "Bishop #{family.name}"
    else
      "#{name} #{family.name}"
    end
  rescue 
    ""
  end

  # TODO this is a very costly operation.  
  # Find out how to cache this in rails. (Maybe it already is??)
  def self.selectionList(current=true)
    return @@names if defined?(@@names)
    names = self.find_all_by_current(true).collect do |person|
      [person.full_name, person.id]
    end
    @@names = names.sort_by{|x| x[0]}
  end

  def self.find_by_full_name(fullName)
    lastName, firstName = fullName.split(",").collect! {|x| x.strip}
    fam = Family.find_all_by_name(lastName)
    fam.each do |family|
      family.people.each do |person|
        if person.name == firstName
          return person
        end
      end
    end
    nil
  end

end
