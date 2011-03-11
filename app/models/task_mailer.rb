class TaskMailer < ActionMailer::Base

  # Sends and email showing all open actions a person has
  def outStandingTodo(person)
    actionItems = person.open_action_items
    subject    "Open Action Items [#{person.full_name}]"
    recipients "kinateder@gmail.com"
    from       "WardAreaBook@WardAreaBook.org"
    sent_on    Time.now
    body       :actionItems => actionItems,
               :person => person
    content_type  "text/html"
  end


  # Sends an email to the hometeacher if their home teacher is 
  # taught or visited by someone other than the home teacher.
  def homeTeachingEvents(hometeacher, events)
    subject    "Your Home Teaching Family was just visited [#{hometeacher.full_name}]"
    recipients "kinateder@gmail.com"
    from       "WardAreaBook@WardAreaBook.org"
    sent_on    Time.now
    body       :hometeacher => hometeacher,
               :events => events
    content_type  "text/html"
  end

  # Sends an email to the EQ President and HP Group Leader for famililes 
  # that don't have HT assigned
  def unassignedFamilyEvents(quorumLeader, events)
    subject    "Unassigned Families [#{quorumLeader.person.full_name}]"
    recipients "kinateder@gmail.com"
    from       "WardAreaBook@WardAreaBook.org"
    sent_on    Time.now
    body       :quorumLeader => quorumLeader,
               :events => events
    content_type  "text/html"
  end

end
