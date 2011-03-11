#!/usr/bin/env ruby
require 'rubygems'


def email_out_standing_todo()
  p Date.today.wday
  if Date.today.wday==2 or Date.today.wday==6
    action_items = ActionItem.find_all_by_status("open")
    people  = Array.new
    action_items.each { |action| people << action.person}
    people.uniq!
    people.each do |person|
      p person.full_name
      TaskMailer.deliver_outStandingTodo(person)
    end
  end
end
  
def email_home_teachers_daily_events()
  hopes = Family.find_by_name("Hope").people[0]
  elders = Family.find_by_name("Elders").people[0]
  events = Event.find_all_by_date_and_person_id(Date.yesterday..Date.today,hopes)
  events += Event.find_all_by_date_and_person_id(Date.yesterday..Date.today,elders)
  events = events.group_by {|event| event.getHomeTeachers}
  events.each do |teachers, events|
    #p "#{teachers}  ======>  #{events}"
    teachers.each do | teacher|
      if teacher.class == Person
        p teacher.full_name
        mail = TaskMailer.deliver_homeTeachingEvents(teacher,events)
        p mail
      else
        p teacher.person.full_name
        mail = TaskMailer.deliver_unassignedFamilyEvents(teacher,events)
        p mail
      end
    end
  end

end

begin
  # load the rails environment
  require File.dirname(__FILE__) + "/../../config/environment"
  email_home_teachers_daily_events
=begin
rescue Exception => e
  puts $!
  p e.backtrace
=end
end

