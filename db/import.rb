#!/usr/bin/env ruby
require 'csv'
require 'rubygems'
require 'sqlite3'
require 'date'

ENV["RAILS_ENV"] ||= "development"
require File.dirname(__FILE__) + "/../config/environment"




#Read contents into the variables
CSV.open('WardList.csv', 'r') do |row|
  # Don't want the first or last values
  unless row[0] == nil or row[0]=='familyname'

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

    row[5] ||= "";
    comment = row[5];

    dates =  comment.gsub(/\/2010/,'').scan(/\d+\/\d+/); 
    events = comment.gsub(/\/2010/,'').split(/\d+\/\d+/); 

    puts familyname


    family = Family.create(:name => lastName, :head_of_house_hold =>headOfHouseHold,
                        :phone => phone, :address => address, :status => status)

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
          print "\t Event (" + date + ") -->" + event[0..100] + "\n";
          month,day = date.split('/');
          year = DateTime.now.year
          
          Event.create(:date => Date.new(year,month.to_i,day.to_i), :family_id => family.id, 
                       :ward_representative_id => '1', :comment => event)
        end
        count = count + 1
      end
    end

    family.save!


=begin

    #Get children
    x=6
    children = ""
    seperator = " | "
    while row[x]
      #1. for now I want to strip out any emails they might have.
      if index = row[x].index('<')
        row[x] = row[x].slice(0, index).strip
      end
      #2. See if the name is included in the family name (I just want children not head of house hold
      unless familyname.include? row[x]

      #3. Converge all of the names into a single string
        children += row[x] + seperator
      end
      x+=1
    end
    children.chomp!(seperator)
    ########################################################################
    # Query the database to see make any updates
    ########################################################################
  begin  
    query = db.execute("select * from families where name == '#{familyname}'" ) 
    
    #If the name is new insert it into the dabase
    if query.size == 0
      # check to see if the address exists (maybe the names changed this is actually quite likely)
      # if so update the family name 
      query = db.execute("select * from families where address == '#{address}'" ) 
      if query.size > 0 
        #update the database and flag
        next 
      end

      #insert into database
      print "Inserting -->", familyname, "\n"
      action = db.execute("insert into families ('name', 'phone','address','status') \
                          VALUES ('#{familyname.gsub(/'/, "''")}','#{phone.gsub(/'/, "''")}', 
                                  '#{address.gsub(/'/, "''") }',  '#{status.gsub(/'/, "''")}')")

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
            status = db.execute("UPDATE families 
                                 SET information='#{event.gsub(/'/, "''")}' 
                                 WHERE family_name == '#{familyname}'")
          else
            print "\t Event (" + date + ") -->" + event[0..100] + "\n";
            action = 
            db.execute("insert into events ('date', 'family_id','ward_representative_id','comment') \
                          VALUES ('#{date.gsub(/'/, "''")}','1','1', 
                                  '#{comment.gsub(/'/, "''") }')")
          end
          count = count + 1
        end
      end
    end
  end

=begin 
    # The family exists check for any updates 
    else 
      # TODO there's got to be a cleaner way
      if query[0][2] != phone
        updateAndFlag(db, familyname, "phone", query[0][2], phone)

      end
      if query[0][3] != address
        updateAndFlag(db, familyname, "address", query[0][3], address)
      end
      if query[0][4] != children
        updateAndFlag(db, familyname, "children", query[0][4], children)
      end
    
      status = db.execute("UPDATE families 
                           SET update_flag='true'
                           WHERE family_name == '#{familyname}'")
    end


    #Check to see if there are an fields that didn't get updated.
    
#    familyname
#    phone
#    address
#    children
  rescue SQLite3::SQLException
    print "Issues with row ", row, "\n"
    raise
  end
#db.execute("select * from Wardlist where name8 != 'U'") do |deleted|
#db.execute("update WardList set name8='U' where familyname == '#{newCSV[0]}'")
#
#
=end

  end
end
=begin
# TODO update the approprate field
db.execute("select * from families where update_flag == 'false'" ) do |row|
  print "No longer have records for -> ", row[1], "\n"
end
    
status = db.execute("UPDATE families SET update_flag='false'")
=end

