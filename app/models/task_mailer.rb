class TaskMailer < ActionMailer::Base
  default :from => "wardareabook@burienwardmission.com"

  # Sends and email showing all open actions a person has
  def outStandingTodo(person)
    @actionItems = person.open_action_items
    @person = person
    mail(:to => person.email, :subject => "Open Action Items [#{person.full_name}]")
  end


  # Sends an email to the hometeacher if their home teacher is 
  # taught or visited by someone other than the home teacher.
  def homeTeachingEvents(hometeacher, events)
    @hometeacher = hometeacher
    @events = events
    mail(:to => hometeacher.email, :subject => "Home Teaching Family - Missionary Visit [#{hometeacher.full_name}]")
  end

  # Sends an email to the EQ President and HP Group Leader for famililes 
  # that don't have HT assigned
  def unassignedFamilyEvents(quorumLeader, events)
    @quorumLeader = quorumLeader
    @events = events
    mail(:to => quorumLeader.email, :subject => "Unassigned Families [#{quorumLeader.person.full_name}]")
  end

end
