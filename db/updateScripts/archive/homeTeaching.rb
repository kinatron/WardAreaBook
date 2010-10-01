#!/usr/bin/env ruby
require 'csv'
require 'rubygems'
require 'sqlite3'
require 'date'
require 'rake'
require 'set'

# load the rails environment
require File.dirname(__FILE__) + "/../../../config/environment"

# TODO Create a copy of the new WardList

# Append to the running log
#$stdout = File.open("HomeTeachingImport.log",'a')
puts Time.now.to_s

def getName(fullName)
  fullName.split(",").collect! {|x| x.strip}
end

def getPerson(fullName)
  begin
    lastName, firstName = getName(fullName)

    family = Family.find_all_by_name(lastName)
    if family.size == 0
      puts "Couldn't find Family --> " + lastName
      return 
    end

    family.each do |fam|
      #puts firstName + "--" + fam.id.to_s
      person = Person.find_by_name_and_family_id(firstName,fam.id)
      if person == nil
        next 
      end
      return person
    end
    #puts "Couldn't find #{fullName}"
    nil
  rescue Exception => e
    puts e
    nil
  end
end

cantFindTeacher = Set.new
cantFindFamily = Set.new
foundFamily = Set.new
foundTeacher = Set.new
TeachingRoute.delete_all()
CSV.open('HomeTeaching.csv', 'r') do |row|
  #skip past the first row
  if row[0] == "Quorum" || row[0] == ""
    next
  end


  #Get the family name
  famName, headOfHouseHold = getName(row[12])
  fam = Family.find_by_name_and_head_of_house_hold(famName,headOfHouseHold)
  if fam == nil
    cantFindFamily.add(row[12])
    next
  else
    foundFamily.add(fam)
  end


  #puts row[6] + " -- " + row[9] + " ---> " + row[12]
  hometeacher1 = getPerson(row[6])
  unless hometeacher1 == nil
    #puts hometeacher1.name + " " + hometeacher1.family.name 
    foundTeacher.add(hometeacher1)
    TeachingRoute.create(:category => row[0], 
                         :person_id => hometeacher1.id, 
                         :family_id => fam.id)
  else
    last, first = getName(row[6])
    name = first + " " + last
    cantFindTeacher.add(name)
    next
  end

  hometeacher2 = getPerson(row[9])
  unless hometeacher2 == nil
    #puts hometeacher2.name + " " + hometeacher2.family.name 
    foundTeacher.add(hometeacher2)
    TeachingRoute.create(:category => row[0], 
                         :person_id => hometeacher2.id, 
                         :family_id => fam.id)
  else
    cantFindTeacher.add(row[9])
  end

end # iterate through the ward list

#puts "Couldn't find Teacher"
#cantFindTeacher.each do |person|
#  puts "\t" + person.to_s
#end

puts "Did find Teacher"
foundTeacher.each do |person|
  puts "\t" + person.name + " " + person.family.name
end

#puts "Couldn't find Family"
#cantFindFamily.each do |family|
#  puts "\t" + family.to_s
#end

puts "Did find Family"
foundFamily.each do |family|
  puts "\t" + family.name 
end







