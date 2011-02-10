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

  ALL = self.find(:all, :order=>'name').map do |s|
    if s.name == "Elder and Sister"
      ["The Hopes", s.id]
    else
      if s.family
        [s.name.split(" ")[0] + " " + s.family.name, s.id]
      else
        [s.name.split(" ")[0], s.id]
      end
    end
  end

  def full_name
    "#{name} #{family.name}"
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

  def Person.get_first_and_last_names

    # TODO this is a very costly operation.  Find out how to cache this.
    @@names ||= self.find(:all, :order=>'name', :limit => '10').map do |s|
      if s.name == "Elder and Sister"
        ["The Hopes", s.id]
      else
        if s.family
          [s.name.split(" ")[0] + " " + s.family.name, s.id]
        else
          [s.name.split(" ")[0], s.id]
        end
      end
    end
  end

end
