#!/usr/bin/env ruby
require 'csv'
require 'rubygems'
require 'sqlite3'
require 'date'
require 'rake'

ENV["RAILS_ENV"] ||= "development"
require File.dirname(__FILE__) + "/../config/environment"

system("rake db:migrate:reset")
#Rake.application.rake_require '../../lib/tasks/metric_fetcher'
#Rake.db:migrate.reset 

# Add the Hopes and the Elders as families and then add them as people "The Hopes" and "The Elders" 
family = Family.create(:name => "Hopes", :head_of_house_hold =>"Elder and Sister",
                        :phone => "206-851-3221", :status => "Active")

Person.create(:name => "The", :family_id => family.id)

family = Family.create(:name => "Elders", :head_of_house_hold =>"Full Time Missionaries",
                        :phone => "206-851-3221", :status => "Active")

Person.create(:name => "The", :family_id => family.id)


#Read contents into the variables
CSV.open('WardList.csv', 'r') do |row|
  # Don't want the first or last values
  unless row[0] == nil or row[0]=='Name'

    ########################################################################
    # Extract the data from the cvs file
    # familyname	phone	addr1	addr2	Status	Comments	name1	name2	name3	name4
    ########################################################################
    # Get family name
    familyname = row[0]
#    puts familyname

    lastName, headOfHouseHold =   familyname.split(/,/)

    lastName.strip!
    headOfHouseHold.strip!
#    puts lastName  + "--"  + headOfHouseHold 
    

    # Get phone
    phone = row[1]
    phone ||= "";

    # Get address
    row[2] ||= "";
    row[3] ||= "";
    address = (row[2] + " " + row[3] +" ").strip
    
    # Get status
    row[4] ||= "";
    status = row[4];


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
    family = Family.find_by_name(lastName)

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
        #If there isn't a date place this in info
        if date == ""
          print "\t Comment -->",event[0..80] , "\n"
          family.information = event
        else
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
                       :ward_representative_id => id, :comment => event, :category => type)
        end
        count = count + 1
      end
    end
  end # skip the first col
end # do (cvs sheet)

