#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'date'
require 'rake'
require 'vpim/vcard'

# This is a flag to determine if I need to clear the cache or not for the ward 
# list index page.
updateMade = false

class VcardPerson
  attr_accessor :name, :email
end

# TODO better log file so that all family updates happen together
def getFamilyMembers cardData
  #create people records from family members
  # Sample vard data  ---> Household members:=0D=0A=Ryan <todd@grail.com>=0D=0A=Jennifer Jones=0D=0A=Joseph Hyrum=0D=0A=Richard Isaac
  #
  familyMembers = []
  personList = cardData.split(/=0D=0A=/);
  personList.shift
  personList.each do |individual| 
    person = VcardPerson.new
    foundEmail = individual.match(/<.*>/)
    if foundEmail
      person.email = foundEmail.to_s[1..(foundEmail.to_s.length-2)].downcase
      person.name = foundEmail.pre_match.strip
    else
      person.name = individual.strip
      person.email = nil
    end
    person.name.gsub!("Uaisele Kalingitoni","Bishop") 
    familyMembers << person
  end
  return familyMembers
end

def downLoadNewList
  #TODO fix this warning
  agent = Mechanize::Mechanize.new
  site = "https://secure.lds.org/units"
  puts "accessing #{site}"
  agent.get(site) do |page|
    form = page.form('loginForm')
    # TODO What happens when you have multiple wards and admins?
    root = RootAdmin.find(:first)
    form.username = root.lds_user_name
    form.password = root.lds_password 
    page = agent.submit(form)
    puts "Just logged in"
    # TODO find out if there is way to search for the links 
    # based on a regex instead of having to cycle through the links
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
    #@doc = Nokogiri::HTML(File.open("leader.html"))

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
      person.gsub!("Uaisele Kalingitoni","Bishop") 
      puts calling + " <==> " + person
      cal = Calling.find_by_job(calling)
      if cal
        cal.person_id = Person.find_by_full_name(person).id
        cal.save!
      else
        Calling.create(:job => calling, :person_id => Person.find_by_full_name(person).id)
      end
    end

  end
end


def quartlyReport
  include StatsHelper
  @totalMembers  = Person.find_all_by_current(true).length
  @total         = Family.find_all_by_current_and_member(true,true, :conditions => "status != 'moved'").length
  @active        = Family.find_all_by_current_and_member_and_status(true,true,'active').length
  @lessActive    = Family.find_all_by_current_and_member_and_status(true,true,'less active').length
  @notInterested = Family.find_all_by_current_and_member_and_status(true,true,'not interested').length
  @dnc           = Family.find_all_by_current_and_member_and_status(true,true,'dnc').length
  @unknown       = Family.find_all_by_current_and_member_and_status(true,true,'unknown').length + 
                   Family.find_all_by_current_and_member_and_status(true,true,'new').length 
  profile =  WardProfile.find_by_quarter(Time.now.at_beginning_of_quarter)  
  if profile == nil
    WardProfile.create(:quarter => Time.now.at_beginning_of_quarter,
                       :total_families => @total,
                       :active => @active,
                       :less_active => @lessActive,
                       :not_interested => @notInterested,
                       :dnc => @dnc,
                       :unknown => @unknown,
                       :new => moveIns(3),
                       :moved => moveOuts(3),
                       :visited => familiesVisited(3))
  else
    profile.total_families = @total
    profile.active = @active
    profile.less_active = @lessActive
    profile.not_interested = @notInterested
    profile.dnc = @dnc
    profile.unknown = @unknown
    profile.new = moveIns(3)
    profile.moved = moveOuts(3)
    profile.visited = familiesVisited(3)
    profile.save
  end
end


begin
  # load the rails environment
  require File.dirname(__FILE__) + "/../../config/environment"

  UPDATEDIR = "#{RAILS_ROOT}/db/updateScripts/"
  # Create a copy of the database
  DATABASE = "#{RAILS_ROOT}/db/#{ENV['RAILS_ENV']}.sqlite3"
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
  Person.update_all("current == 0")
  Family.find_all_by_member(true).each do |family|
    family.current = false
    family.save
  end

  # Find the Hopes and Elders make them current because 
  # they won't show up in the new  ward list
  # TODO you need to better account for missionaries.
  #
  hopes = Family.find_by_name("Hope")
  hopes.current=1
  hopes.save
  hopes = Person.find(1)
  hopes.current=1
  hopes.save

  elders = Family.find_by_name("Elders")
  elders.current=1
  elders.save
  elders = Person.find(2)
  elders.current=1
  elders.member=0
  elders.save

  cards = Vpim::Vcard.decode(open("#{UPDATEDIR}/WardList.vcf"))
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
      Person.update_all("current == 0","family_id == #{family.id}")

      vcardMembers = getFamilyMembers card.note
      vcardMembers.each { |new| 
        person = Person.find_by_name_and_family_id(new.name,family)
        # if the person exists make them current and then verify the email address
        if person
          if new.email && person.email != new.email 
            puts "\t  updating email <" + new.email + "> for " + new.name + " " + family.name
            person.email = new.email
          end
          person.current = true
          person.save
          # otherwise create new person
        else
          if new.email 
            puts "\t  Creating person :" + new.name + " with email :" + new.email 
          else
            puts "\t  Creating person :" + new.name 
          end
          Person.create(:name => new.name, :email => new.email, 
                        :family_id => family.id, :current => true)
        end
      }

      removed = Person.find_all_by_family_id_and_current(family.id, 0) - alreadyRemoved
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
                             :phone => phone, :address => address, :status => "new", 
                             :uid => uid, :current => 1)
      family.events.create(:date => Date.today, 
                           :category => "MoveIn",
                           :comment => "Received records from SLC")
      updateMade = true

      #create people records from family members
      # Sample vard data  ---> Household members:=0D=0A=Ryan <todd@grail.com>=0D=0A=Jennifer Jones=0D=0A=Joseph Hyrum=0D=0A=Richard Isaac
      #

      vcardMembers = getFamilyMembers card.note
      vcardMembers.each { |person| 
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
      family.events.create(:date => Date.today,
                           :category => "MoveOut",
                           :comment => "Records removed from the Ward")
      # make all of the family members not current
      Person.update_all("current == 0","family_id == #{family.id}")
      family.save
      updateMade = true
    end
  end

  puts "\n"

  quartlyReport

rescue Exception => e
  puts $!
  p e.backtrace
  copy(BACKUP,DATABASE)
end

# Clear the cache if any updates are made.
if updateMade
  system("rm -rf #{RAILS_ROOT}/public/cache/views/*")
end
