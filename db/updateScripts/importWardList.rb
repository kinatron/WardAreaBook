#!/usr/bin/env ruby
require 'csv'
require 'rubygems'
require 'sqlite3'
require 'date'
require 'rake'

# load the rails environment
require File.dirname(__FILE__) + "/../../config/environment"

# TODO Create a copy of the new WardList

# Create a copy of the database
# TODO Get the database name from the environment
#copy("production.sqlite3","bak/"+Time.now.to_s+"  - production.sqlite3")
copy("../development.sqlite3","bak/"+Time.now.to_s+"  - development.sqlite3")

# Append to the running log
#$stdout = File.open("WardListImport.log",'a')
#puts Time.now.to_s


########################################################################
# Extract the data from the cvs file
# familyname,  phone,   addr1,   addr2,  addr3,   addr4,   name1,   name2,  name3,   name4
########################################################################
# set all records to non current
# TODO
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

# unfortunate hacks :(
hack = Family.find(308)
hack.head_of_house_hold = "Craig William"
hack.save

hack = Family.find(128)
hack.head_of_house_hold = "Harvey Kay and Veletta Mae"
hack.save

hack = Family.find(43)
hack.head_of_house_hold = "Mark Alan and Melanie Rose Clark"
hack.save

hack = Family.find(44)
hack.head_of_house_hold = "Sheri"
hack.save

hack = Family.find(208)
hack.head_of_house_hold = "Viliami Sisi Toutai and Lili"
hack.save

hack = Family.find(390)
hack.head_of_house_hold = "Viliami Po'uli Kae'eva and Lynn"
hack.save

hack = Family.find(252)
hack.head_of_house_hold = "Shirley Dianna"
hack.save

hack = Family.find(286)
hack.head_of_house_hold = "Tammy"
hack.save

CSV.open('WardList.csv', 'r') do |row|

  # Don't want the first or last values
  unless row[0] == nil or row[0]=='Family Name'
    familyname = row[0]

    lastName, headOfHouseHold =   row[1].split(/,/)
    headOfHouseHold.gsub!("&", "and")

    lastName.strip!
    headOfHouseHold.strip!

    # Get phone
    phone = row[2]
    phone ||= "";

    # Get the address
    row[2] ||= "";
    row[3] ||= "";
    address = (row[4]).strip

    # Find out if this is a new family. 
    # Check for variations on the head of house hold names
    # Check for existing phone numbers 
    # Check for existing addresses.

    family = Family.find(:first, 
                         :conditions => ["UPPER(name)= ? and UPPER(head_of_house_hold) = ?", 
                                          lastName.upcase, headOfHouseHold.upcase])

    if (family == nil and  # hack some exceptions
       (lastName.downcase != "conn" and lastName.downcase != "linville" and
        lastName.downcase != "tupou" ))

      # Users may update their preferred name, so check for slight variations
      familyList =  Family.find_all_by_name(lastName)

      # if there is a common name between the new headOfHouseHold and the 
      # existing one then the head of household names have changed and it 
      # will not be interpreted as a new family
      # Jeff --> Jeff and Tanya
      # Michael Vern and Stacy - Mike and Stacy
      # William and Debbie --> Bill and Debbie
      newFamily = true
      familyId = 0
      familyList.each  do | fam | 
        currentNames = fam.head_of_house_hold.upcase.split.to_set
        currentNames.delete("AND")
        currentNames.delete("&")
        newNames = headOfHouseHold.upcase.split.to_set
        newNames.delete("AND")
        newNames.delete("&")
        result = currentNames & newNames
        if result.size > 0 
          newFamily = false
          familyId = fam.id;
          break
        end

        # Check for existing phone numbers 
        if fam.phone == phone and phone != ""
          newFamily = false
          familyId = fam.id;
          break
        end

        # Check for existing addresses.
        if fam.address == address and address != ""
          newFamily = false
          familyId = fam.id;
          break
        end
      end

      if newFamily
        puts "  *** New Family *** ";
        puts "  \t" + lastName  + "," + headOfHouseHold
        puts "  \t" + phone;
        puts "  \t" + address;
        puts "\n"
        # Create the new family
        # Set status 
        # label them as current

        family = Family.create(:name => lastName, :head_of_house_hold =>headOfHouseHold,
                               :phone => phone, :address => address, :status => "new")

        # Create people records from person columns 
        # "Ryan <kinateder@gmail.com>", "Jennifer Jones"
        # while the rest of the columns are not empty
        #
        col = 6
        # This is to handle a couple of exceptions
        if row[col] == nil
          Person.create(:name => headOfHouseHold, :family_id => family.id)
        else
          while row[col] != nil do 

            # this is to capture any emails
            person = row[col].match(/<.*>/)

            #If there are not emails just Use what's ever in the column
            if person == nil
              Person.create(:name => row[col].strip, 
                            :family_id => family.id)
            else
              # insert both the person name and email
              Person.create(:name => person.pre_match.strip, 
                            :email => person.to_s[1..(person.to_s.length-2)],
                            :family_id => family.id)
            end
            col += 1
          end # while loop
        end
        next
      end

      # Grab the family name as we continue
      family = Family.find(familyId)
    end

    # update family info
    # if there is a change update and log it
    if family.name != lastName or family.head_of_house_hold != headOfHouseHold or
      family.phone != phone   or family.address != address

      puts "\t" + family.name  + "," + family.head_of_house_hold + " update"
      if family.name != lastName 
        puts "\t  familyName : " + family.name + "--->" + lastName
        family.name = lastName
      end
      if family.head_of_house_hold != headOfHouseHold 
        puts "\t  Head of House Hold: : " + family.head_of_house_hold + "--->" + headOfHouseHold
        family.head_of_house_hold = headOfHouseHold
      end
      if family.phone != phone 
        puts "\t  phone      : " + family.phone + "--->" + phone
        family.phone = phone
      end
      if family.address != address 
        puts "\t  address    : " + family.address + "--->"+  address
        family.address = address
      end
    end

    # label them as current
    family.current=1
    # TODO
    family.save
  end # skip past the first, or any empty rows
end # iterate through the ward list

    # Get all of the non-current families. 
    # Find all that don't have a status of "Moved - Old Record" and print those to a report
    # change status of those families to   "Moved - Old Record"
    #
    # Read CVSFile

# TODO this seems like a really bad flaw with rails and the sqlite database
# having some booleans use 0,1 and others use true, false
moved = Family.find_all_by_current_and_member(0,true)

# TODO gotta be a more elegant way to determine if we need to print
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


    # Get status
    row[4] ||= "";
    case row[4]
    when /dnc/i       ; status = "dnc"
    when /less/i      ; status = "less active"
    when /active/i    ; status = "active"
    when /mailing/i   ; status = "not interested"
    when /interested/i; status = "not interested"
    when /moved/i     ; status = "moved"
    else  status = 'Unknown - ' + row[4]
    end

    puts familyname


    family = Family.create(:name => lastName, :head_of_house_hold =>headOfHouseHold,
                           :phone => phone, :address => address, :status => status)

    # Create people records from person columns 
    # "Ryan <kinateder@gmail.com>", "Jennifer Jones"
    # while the rest of the columns are not empty
    #
    col = 6
    # This is to handle a couple of exceptions
    if row[col] == nil
      Person.create(:name => headOfHouseHold, :family_id => family.id)
    else
      while row[col] != nil do 

        # this is to capture any emails
        person = row[col].match(/<.*>/)

        #If there are not emails just Use what's ever in the column
        if person == nil
          Person.create(:name => row[col].strip, 
                        :family_id => family.id)
        else
          # insert both the person name and email
          Person.create(:name => person.pre_match.strip, 
                        :email => person.to_s[1..(person.to_s.length-2)],
                        :family_id => family.id)
        end
        col += 1
      end # while loop
    end

    family.save!
  end
end


# Cycle back through the ward list and add events
CSV.open('WardList.csv', 'r') do |row|
  # Don't want the first or last values
  unless row[0] == nil or row[0]=='Name'

    # Get the family 
    lastName, headOfHouseHold =   row[0].split(/,/)
    lastName.strip!
    headOfHouseHold.strip!
    family = Family.find_by_name_and_head_of_house_hold(lastName,headOfHouseHold)

    row[5] ||= "";
    comment = row[5];

    dates =  comment.gsub(/\/2010/,'').scan(/\d+\/\d+/); 
    events = comment.gsub(/\/2010/,'').split(/\d+\/\d+/); 

    puts family.name
    # Add any events                                  
    count = 0;
    events.each do |event|
      if event != ""
        date = dates[count];
        date ||= ""

        #create the event and comments.
        #If there isn't a date place this into family.information
        if date == ""
          print "\t Comment -->",event[0..80] , "\n"
          family.information = event
          family.save
        else

          # strip a leading ( or trialing )
          event.gsub!(/^\(/,'')
          event.gsub!(/^\)/,'')
          event.gsub!(/\)$/,'')
          event.gsub!(/\($/,'')
          event.strip!

          print "\t Event (" + date + ") -->" + event + "\n";
          month,day = date.split('/');
          year = DateTime.now.year

          # d) For Events guess 
          #    - ward rep "Hope" "Kinateder" else Bishop Puloka
          #    - event type - Lesson | prayer => Lesson, "no.*home" => Attempt, else => Visit
          case event 
          when /lesson|prayer|message/i; type = "Lesson"
          when /no.*home/i; type = "Attempt"
          else
            type = "Visit"
          end

          case event 
          when /hope/i;      id = Person.find_by_name("The").id
          when /elder/i;     id = Person.find_by_name("The").id + 1
          when /kinateder/i; id = Person.find_by_name("Ryan").id
          when /no.*home/i;  id = Person.find_by_name("The").id
          else
            id = Person.find_by_name("Bishop").id
          end

          Event.create(:date => Date.new(year,month.to_i,day.to_i), :family_id => family.id, 
                       :person_id => id, :comment => event, :category => type)
        end
        count = count + 1
      end
    end
  end # skip the first col
end # do (cvs sheet)
=end

