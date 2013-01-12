class Person < ActiveRecord::Base
  belongs_to :family
  has_many :teachingRoutes 

  has_and_belongs_to_many :visiting_teachers, {:join_table => "visiting_teaching_routes", :class_name => "Person", :foreign_key => "person_id", :association_foreign_key => "visiting_teacher_id"}
  has_and_belongs_to_many :visit_teach, {:join_table => "visiting_teaching_routes", :class_name => "Person", :foreign_key => "visiting_teacher_id", :association_foreign_key => "person_id"}

  has_many :action_items 
  has_many :events
  has_many :open_action_items, :class_name => "ActionItem",
                               :conditions => "status = 'open'",
                               :order => 'due_date ASC, updated_at DESC'
  has_many :closed_action_items, :class_name => "ActionItem",
                                 :conditions => "status = 'closed'",
                                 :order => 'updated_at DESC'
  has_many :calling_assignments, :dependent => :destroy
  has_many :callings, :through => :calling_assignments, :order => "callings.access_level DESC"

  has_and_belongs_to_many :visiting_teachers, {:join_table => "visiting_teaching_routes", :class_name => "Person", :foreign_key => "person_id", :association_foreign_key => "visiting_teacher_id"}
  has_and_belongs_to_many :visit_teach, {:join_table => "visiting_teaching_routes", :class_name => "Person", :foreign_key => "visiting_teacher_id", :association_foreign_key => "person_id"}

  attr_accessible :name, :email, :family_id, :current, :uid, :phone, :calling_assignments_attributes
  accepts_nested_attributes_for :calling_assignments, allow_destroy: true

  # callings are in descending order by access level, so the first will be the highest
  def access_level
    call = callings.first
    if call.nil?
      return 1
    else
      call.access_level
    end
  end

  def full_name
    if Calling.find_by_job("Bishop").people.include? self
      "Bishop #{family.name}"
    else
      "#{name} #{family.name}"
    end
  rescue
    name
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
