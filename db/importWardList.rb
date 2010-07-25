#!/usr/bin/env ruby
require 'csv'
require 'rubygems'
require 'sqlite3'
require 'date'
require 'rake'

require File.dirname(__FILE__) + "/../config/environment"

########################################################################
# Extract the data from the cvs file
# familyname,  phone,   addr1,   addr2,  addr3,   addr4,   name1,   name2,  name3,   name4
########################################################################
# set all records to non current
Family.update_all("current == 0");
CSV.open('WardList.csv', 'r') do |row|

  # Don't want the first or last values
  unless row[0] == nil or row[0]=='familyname'
    familyname = row[0]
    #    puts familyname

    lastName, headOfHouseHold =   familyname.split(/,/)

    lastName.strip!
    headOfHouseHold.strip!

    # Get phone
    phone = row[1]
    phone ||= "";

    # Get the address
    row[2] ||= "";
    row[3] ||= "";
    address = (row[2] + " " + row[3] + " " + row[4] + " " + row[5]).strip

    # Find out if this is a new family. 

    family = Family.find(:first, 
                         :conditions => ["UPPER(name)= ? and UPPER(head_of_house_hold) = ?", 
                                          lastName.upcase, headOfHouseHold.upcase])
    # New family
    if (family == nil) 
      # Users may update their preferred name, so check for slight variations
      puts "New Family *** "  + lastName  + "," + headOfHouseHold
      
      family =  Family.find_all_by_name(lastName)

      # William and Debbie --> Bill and Debbie
      # Jeff --> Jeff and Tanya
      # Michael Vern and Stacy - Mike and Stacy
      for family.each  do | fam | 
        if true
          #fam.head_of_house_hold.upcase.include?  headOfHouseHold.upcase
          puts " Existing Family " + lastName  + "," + headOfHouseHold 
        end
      end
      #next
    end





      # Create the new family
      # Set status 
      # label them as current


=begin

    # update family info
    # label them as current
    puts "Updating the " + lastName + "," + headOfHouseHold + " Family"
    if family.name != lastName 
      puts "                 " + family.name 
      puts "                 " + lastName 
      family.name = lastName
      #family.save
    end
    if family.head_of_house_hold != headOfHouseHold 
      puts "                 " + family.head_of_house_hold 
      puts "                 " + headOfHouseHold
      family.head_of_house_hold = headOfHouseHold
      #family.save
    end
    if family.phone != phone 
      puts "                 " + family.phone 
      puts "                 " + phone 
      family.phone = phone
      #family.save
    end
    if family.address != address 
      puts "                 " + family.address
      puts "                 " + address 
      family.address = address
      #family.save
    end
=end
  end
end

    # Get all of the non-current families. 
    # Find all that don't have a status of "Moved - Old Record" and print those to a report
    # change status of those families to   "Moved - Old Record"
    #
    # Read CVSFile
    





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

