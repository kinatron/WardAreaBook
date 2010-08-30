#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'rake'
require 'vpim/vcard'

# load the rails environment
require File.dirname(__FILE__) + "/../../config/environment"


# Create a copy of the database
# TODO Get the database name from the environment
#copy("production.sqlite3","bak/"+Time.now.to_s+"  - production.sqlite3")
copy("../development.sqlite3","../bak/"+Time.now.to_s+"  - development.sqlite3")
 
# TODO Append to the running log
#$stdout = File.open("WardListImport.log",'a')
puts Time.now.to_s


########################################################################
# Extract the data from the cvs file
# familyname,  phone,   addr1,   addr2,  addr3,   addr4,   name1,   name2,  name3,   name4
########################################################################
# set all records to non current
Family.update_all("current == 0")

# Find the Hopes and Elders make them current because 
# they won't show up in the new  ward list
#
hopes = Family.find_by_name("Hope")
hopes.current=1
hopes.save

elders = Family.find_by_name("Elders")
elders.current=1
elders.save


cards = Vpim::Vcard.decode(open("WardList.vcf"))
cards.each do |card|
  lastName = card.name.family.strip
  lastName ||= "" 
  headOfHouseHold = card.name.given.strip
  headOfHouseHold ||= "" 
  phone = card.telephone
  phone ||= "" 
  address = (card.address.street + " " + card.address.locality + " " + card.address.region).strip
  address ||= "" 
  uid = card.value("UID")

  # Hack TODO - I think there is more elegant solution but for now take 
  # Bishops name from the ward list and replace it with Bishop
  if lastName == "Puloka"
    headOfHouseHold.gsub!("Uaisele Kalingitoni","Bishop") 
  end

  family = Family.find_by_uid(uid)

  # If the uid exists check for any updates
  if family

    #check for updates in the family
    family.people.each { |person| puts person.name }





    exit

    # update family info
    # if there is a change update and log it
    if family.name != lastName or family.head_of_house_hold != headOfHouseHold or
       family.phone != phone   or family.address != address

      puts "\t" + family.name  + "," + family.head_of_house_hold + " update"
      if family.name != lastName 
        puts "\t  familyName          : " + family.name + "--->" + lastName
        family.name = lastName
      end
      if family.head_of_house_hold != headOfHouseHold 
        puts "\t  Head of House Hold: : " + family.head_of_house_hold + "--->" + headOfHouseHold
        family.head_of_house_hold = headOfHouseHold
      end
      if family.phone != phone 
        puts "\t  phone               : " + family.phone + "--->" + phone
        family.phone = phone
      end
      if family.address != address 
        puts "\t  address             : " + family.address + "--->"+  address
        family.address = address
      end
      puts ""
      #TODO what about the chilren!!! and other family members
      #puts card.note
    end

    # label them as current
    family.current=1
    family.save

  # Create a new family record
  else

    puts "  *** New Family *** ";
    puts "  \t" + lastName  + "," + headOfHouseHold
    puts "  \t" + phone;
    puts "  \t" + address;
    puts ""
    # Create the new family
    # Set status 
    # label them as current

    family = Family.create(:name => lastName, :head_of_house_hold =>headOfHouseHold,
                           :phone => phone, :address => address, :status => "New", 
                           :uid => uid, :current => 1)

    #create people records from family members
    # Sample vard data  ---> Household members:=0D=0A=Ryan <kinateder@gmail.com>=0D=0A=Jennifer Jones=0D=0A=Joseph Hyrum=0D=0A=Richard Isaac
    #
    familyMembers = card.note.split(/=0D=0A=/);
    familyMembers.shift
    familyMembers.each do |person| 
      foundEmail = person.match(/<.*>/)
      if foundEmail
        email = foundEmail.to_s[1..(foundEmail.to_s.length-2)]
        person = foundEmail.pre_match.strip
        Person.create(:name => person, :family_id => family.id,
                      :email => email)
      else
        person.strip!
        Person.create(:name => person, :family_id => family.id)
      end
    end
  end
end


# Get all of the non-current families. 
# Find all that don't have a status of "Moved - Old Record" and print those to a report
# change status of those families to   "Moved - Old Record"
#

# TODO this seems like a really bad flaw with rails and the sqlite database
# having some booleans use 0,1 and others use true, false
moved = Family.find_all_by_current_and_member(0,true)

# TODO gotta be amore elegant way to determine if we need to print
# "Familes moved out.  --- Database query
newMoveOuts = false;
moved.each do |family|
  if family.status != "Moved - Old Record"
    newMoveOuts = true
    break
  end
end


if newMoveOuts 
  puts "\tFamilies moved out:"
end
moved.each do |family|
  if family.status != "Moved - Old Record"
    puts "\t\t" + family.name + "," + family.head_of_house_hold
    family.status = "Moved - Old Record"
    family.save
  end
end

puts "\n"

=begin

    card.each do |field|
      puts "..#{field.name.capitalize}=#{field.value.inspect}"

      if field.group
        puts " group=#{field.group}"
      end

      field.each_param do |param, values|
        puts " #{param}=[#{values.join(", ")}]"
      end
    end

=end
# TODO clear the cache if any updates are made.
