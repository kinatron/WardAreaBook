#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'date'
require 'rake'
require 'json'

# This is a flag to determine if I need to clear the cache or not for the ward 
# list index page.
updateMade = false

class JsonPerson
  attr_accessor :name, :email, :uid, :lastName
  def initialize(person)
    @name,@uid,@email = person['preferredName'],person['individualId'],person['email']
    @lastName, @name = @name.split(/,/)
    @name.strip!
    @email.strip!
    if @email.empty? 
      @email = nil 
    else
      @email.downcase!
    end
    #@uid.strip!
    @lastName.strip!
    #puts "\t#{name} \t#{id} \t#{email}"
  end
end

# TODO better log file so that all family updates happen together
def getFamilyMembers family
  familyMembers = []
  head = family['headOfHouse']
  familyMembers << JsonPerson.new(head)
  spouse = family['spouse']
  familyMembers << JsonPerson.new(spouse) if spouse
  children = family['children']
  children.each do |child|
    familyMembers << JsonPerson.new(child)
  end

  return familyMembers
end

def downLoadNewList
  #TODO fix this warning
  agent = Mechanize.new
  site = "https://signin.lds.org/SSOSignIn/"
  puts "accessing #{site}"
  agent.get(site) do |page|
    #TODO brittle....
    form = page.forms.find { |form| form.fields.length > 1 }
    # TODO What happens when you have multiple wards and admins?
    root = RootAdmin.find(:first)
    form.username = root.lds_user_name
    form.password = root.lds_password 
    page = agent.submit(form)
    puts "Just logged in"
    # TODO find out if there is way to search for the links 
    # based on a regex instead of having to cycle through the links
=begin
    page.links.each do |link|
      if link.text =~ /Membership Directory/i
        page = link.click
        break
      end
    end
    vcardHref = ""
    page.links.each do |link| 
      if link.text =~ /vcard/i
        line = link.href.match(/\'.*\'/)
        vcardHref = line.to_s[1..(line.to_s.length-2)]
        break
      end
    end
    puts "Downloading the ward list"
    agent.get(vcardHref).save_as("#{UPDATEDIR}/WardList.vcf")
    puts "Done"
=end
  list_location = "#{UPDATEDIR}/WardList.json"
  FileUtils.mv(list_location, list_location + ".old") if File.exists? list_location
  agent.get("https://lds.org/directory/services/ludrs/mem/member-detaillist/25542").save_as(list_location)
  puts "just retrieved the list"

=begin
    puts "Getting leadership information"
    page.links.each do |link|
      if link.text =~ /Leadership Directory/i
        page = link.click
        break
      end
    end
    leaders = ""
    page.links.each do |link| 
      if link.text =~ /Abbreviated/i
        line = link.href.match(/\'.*\'/)
        leaders = line.to_s[1..(line.to_s.length-2)]
        break
      end
    end

    @doc = agent.get(leaders)
    #@doc = Nokogiri::HTML(File.open("Burien Ward Leadership.html"))

    callings = Array.new
    record = false
    calling = ""

    @doc.parser.css(".eventsource").each do |row|
    #@doc.css(".eventsource").each do |row|
      token = row.text.strip
      if calling != ""
        callings << [calling,token]
        calling = ""
      else 
        if token =~ /:/
          calling = token.chomp(":")
        end
      end
    end

    # Hope hack
    missionary = "Fulltime Missionaries"
    fullTime = Calling.find_by_job(missionary)
    if fullTime == nil
      Calling.create(:job => missionary, :person_id =>1, :access_level => 2)
    end

    callings.each do |calling,person|
      #puts calling + " <==> " + person
      cal = Calling.find_by_job(calling)
      if cal
        cal.person_id = Person.find_by_full_name(person).id
        cal.save!
      else
        Calling.create(:job => calling, :person_id => Person.find_by_full_name(person).id)
      end
    end

=end
  end
end






begin
  # load the rails environment
  require File.dirname(__FILE__) + "/../../config/environment"

  UPDATEDIR = "#{Rails.root}/db/updateScripts/"
  # Create a copy of the database
  DATABASE = "#{Rails.root}/db/#{ENV['RAILS_ENV']}.sqlite3"
  BACKUP = "#{UPDATEDIR}/bak/#{Time.now.strftime("%c")}-#{ENV['RAILS_ENV']}.sqlite3"
  copy(DATABASE,BACKUP)

  downLoadNewList 


  $stdout = File.open("#{UPDATEDIR}/WardListImport.log",'a')
  puts Time.now.strftime("%a %b %d %Y - %I:%M %p")

  ########################################################################
  # Extract the data from the cvs file
  # familyname,  phone,   addr1,   addr2,  addr3,   addr4,   name1,   name2,  name3,   name4
  ########################################################################
  # set all records to non current
  Person.update_all(:current => false)
  Family.find_all_by_member(true).each do |family|
    family.current = false
    family.save
  end

  jsonString = File.open("#{UPDATEDIR}/WardList.json", "r").read
  ward = JSON.parse(jsonString)
  ward.each do |jsonEntry|
    uid   = jsonEntry['headOfHouseIndividualId']
    coupleName = jsonEntry['coupleName']
    lastName, headOfHouseHold = coupleName.split(/,/)
    lastName.strip!
    headOfHouseHold.strip!
    headOfHouseHold.gsub!("&", "and")
    address    = jsonEntry['desc1'] + " " + jsonEntry['desc2']
    phone      = jsonEntry['phone']
    lastName ||= "" 
    headOfHouseHold ||= "" 
    phone ||= "" 
    address ||= "" 

    family = Family.find_by_uid(uid)

    # If the uid exists check for any updates
    if family
      # update family info
      # if there is a change update and log it
      if family.name != lastName or family.head_of_house_hold != headOfHouseHold or
        family.phone != phone   or family.address != address
        puts "\t" + family.name  + "," + family.head_of_house_hold + " update"
        updateMade = true

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
      end
      ########################
      # Update Family members
      #
      # Make all family members not current and then make them
      # current if they appear in new ward list.
      # For my report I want a list of those people already removed
      alreadyRemoved = Person.find_all_by_family_id_and_current(family.id,0)
      Person.update_all({:current => false}, {:family_id => family.id})

      familyMembers = getFamilyMembers jsonEntry
      familyMembers.each { |new| 
        person = Person.find_by_name_and_family_id(new.name,family)
        # if the person exists make them current and then verify the email address
        if person
          if (person.email != new.email) 
            puts "\t  updating email: (#{person.email}) --> (#{new.email}) for " + new.name + " " + family.name
            person.email = new.email
          end
          person.current = true
          person.save
          # otherwise create new person
        else
          unless new.email == nil
            puts "\t  Creating person :" + new.name + " with email :" + new.email 
          else
            puts "\t  Creating person :" + new.name 
          end
          Person.create(:name => new.name, :email => new.email, 
                        :family_id => family.id, :current => true)
        end
      }

      removed = Person.find_all_by_family_id_and_current(family.id, false) - alreadyRemoved
      removed.each { |person| 
        #eventually delete these people if they are not tied to an event
        puts "\t  #{person.name} #{family.name} is no longer current"
      }

      #Flag if this is a moved out record that is returning.
      if family.status == "Moved - Old Record"
        family.status = "Returned Record"
        puts "  *** Returned Record ***"
        puts "\t#{lastName}, #{headOfHouseHold}"
        updateMade = true
      end

      # label the family as current
      family.current=true
      family.member=true
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
                             :phone => phone, :address => address, :status => "new", 
                             :uid => uid, :current => true)
      family.events.create(:date => Date.today, 
                           :category => "MoveIn",
                           :comment => "Received records from SLC")
      updateMade = true

      #create people records from family members
      # Sample vard data  ---> Household members:=0D=0A=Ryan <todd@grail.com>=0D=0A=Jennifer Jones=0D=0A=Joseph Hyrum=0D=0A=Richard Isaac
      #

      familyMembers = getFamilyMembers jsonEntry
      familyMembers.each { |person| 
        print "\t  Creating person :" + person.name
        unless person.email == nil or person.email == "" 
          print " with email :" + person.email 
        end
        puts ""
        Person.create(:name => person.name, :email => person.email, 
                      :family_id => family.id, :current => true)
      }

    end
  end


  # Get all of the non-current families. 
  # Find all that don't have a status of "Moved - Old Record" and print those to a report
  # change status of those families to   "Moved - Old Record"
  #

  moved = Family.find_all_by_current_and_member(false,true)

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
      family.events.create(:date => Date.today,
                           :category => "MoveOut",
                           :comment => "Records removed from the Ward")
      # make all of the family members not current
      Person.update_all({:current => false}, {:family_id => family.id})
      family.save
      updateMade = true
    end
  end

  puts "\n"

  #email_out_standing_todo
  #email_home_teachers_daily_events

  #quartlyReport

  # Clear the cache if any updates are made.
  if updateMade
    system("rm -rf #{Rails.root}/public/cache/views/*")
  end
  #remove(BACKUP)
  puts "Finished update at #{Time.now}"

rescue Exception => e
  puts "Here we are"
  puts $!
  p e.backtrace
  copy(BACKUP,DATABASE)
end
