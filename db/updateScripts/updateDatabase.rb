#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'date'
require 'rake'
require 'json'

# load the rails environment
require File.dirname(__FILE__) + "/../../config/environment"

# TODO Eventually this needs to be made multi-tenant so that it can work for multiple wards,
# for now we'll just use a constant for the ward id
WARD_ID = 25542
ORGANIZATIONS_TO_GET = [1179, 69]
DEFAULT_PERMISSION_LEVEL = 1
POSITION_TO_LEVEL = {
  "4" => 3,
  "54" => 3,
  "55" => 3
}

UPDATEDIR = "#{Rails.root}/db/updateScripts/"
CALLINGS_LOCATION = "#{UPDATEDIR}callings_lists";

class JsonPerson
  attr_accessor :name, :email, :uid, :lastName
  def initialize(person)
    @name = person['preferredName']
    @uid = person['individualId']
    @email = person['email']
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

def downLoadNewInfo
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

    list_location = "#{UPDATEDIR}WardList.json"
    FileUtils.mv(list_location, list_location + ".old") if File.exists? list_location
    agent.get("https://lds.org/directory/services/ludrs/mem/member-detaillist/#{WARD_ID}").save_as(list_location)
    puts "just retrieved the list"

    puts "Getting leadership information"

    FileUtils.rm_rf(CALLINGS_LOCATION + ".old") if File.exists? CALLINGS_LOCATION + ".old"
    FileUtils.mv(CALLINGS_LOCATION, CALLINGS_LOCATION + ".old") if File.exists? CALLINGS_LOCATION
    Dir.mkdir(CALLINGS_LOCATION)

    ORGANIZATIONS_TO_GET.each do |org_id|

      agent.get("https://www.lds.org/directory/services/ludrs/1.1/unit/stake-leadership-group-detail/#{WARD_ID}/#{org_id}/1").save_as("#{CALLINGS_LOCATION}/#{org_id}.json")
      puts "just retrieved callings for #{org_id}"

    end
=begin
    Looks like you retrieve the leadership roster from:
    https://www.lds.org/directory/services/ludrs/1.1/unit/stake-leadership-group-detail/{ward id}/{organization id}/1

    Thorton Creek High Priest Group:
    https://www.lds.org/directory/services/ludrs/1.1/unit/stake-leadership-group-detail/25542/69/1

    Example JSON (Thorton Creek Bishopric):
    {
      "leaders":[
        {
          "callingName":"Bishop",
          "displayName":"Stephen Wade Standage",
          "email":"brotherstandage@gmail.com",
          "householdPhoneNumber":"206-729-2409",
          "individualId":3056998278, #TODO We need to keep these when we do the ward list import, so we can match it up here
          "phoneNumber":"206-491-0689",
          "photoUri":"",
          "positionId":4
        },
        {"callingName":"Bishopric First Counselor","displayName":"David Pickett","email":"dpickett82@gmail.com","householdPhoneNumber":"206-395-4364","individualId":2879176527,"phoneNumber":"2063954364","photoUri":"","positionId":54},
        {"callingName":"Bishopric Second Counselor","displayName":"Andrew David Forbes","email":"drew.forbes@gmail.com","householdPhoneNumber":"1-206-659-3055","individualId":19700743384,"phoneNumber":"1-206-659-3055","photoUri":"","positionId":55},
        {"callingName":"Ward Executive Secretary","displayName":"Ben Newman","email":"thorntoncreekexecsec@gmail.com","householdPhoneNumber":"801 368 1785","individualId":902144318,"phoneNumber":"801 368 1785","photoUri":"","positionId":56},
        {"callingName":"Ward Clerk","displayName":"Mitch Jones","email":"aaronmitchelljones@gmail.com","householdPhoneNumber":"8012288094","individualId":20570694452,"phoneNumber":"801-228-8094","photoUri":"","positionId":57},
        {"callingName":"Ward Assistant Clerk--Finance","displayName":"Alex Quistberg","email":"aquistbe@gmail.com","householdPhoneNumber":"1-206-607-9179","individualId":1182115497,"phoneNumber":"1-206-607-9179","photoUri":"","positionId":786},
        {"callingName":"Ward Assistant Clerk--Membership","displayName":"Brian Turner","email":"","householdPhoneNumber":"206-363-9228","individualId":2578173080,"phoneNumber":"206-786-4017","photoUri":"","positionId":787}
      ],
      "unitName":"Thornton Creek Ward"
    }

    ward ids
    thorton creek -- 25542

    organization ids
    1179 -- Bishopric
    69 -- High Priest Group
    70 -- Elders Quorum
    74 -- Relief Society
    75 -- Sunday School
    73 -- Young Men
    76 -- Young Women
    77 -- Primary
    1300 -- Music
    1298 -- Family History
    1309 -- Technology
    1310 -- Ward Missionaries
=end
  end
end


def parse_callings
  puts "Parsing Calings"

  unless File.directory?(CALLINGS_LOCATION)
    puts "Missing callings folder #{CALLINGS_LOCATION}, can't parse callings"
    return
  end

  Dir.foreach(CALLINGS_LOCATION) do |filename|
    fullFileName = File.join(CALLINGS_LOCATION, filename)
    puts "Skipping because its a directory: #{fullFileName}" if File.directory?(fullFileName)
    next if File.directory?(fullFileName)

    puts "Parsing callings out of: #{fullFileName}"

    jsonString = File.open(fullFileName, "r").read
    callings = JSON.parse(jsonString)

    callings['leaders'].each do |jsonEntry|
      personId = Person.where(:uid => jsonEntry['individualId']).first.id
      positionId = jsonEntry['positionId']
      cal = Calling.where(:position_id => positionId).first
      callingName = jsonEntry['callingName']

      puts "Mapping person id: #{personId} to #{callingName}(#{positionId})"

      if cal
        cal.person_id = personId
        cal.save!
      else
        level = POSITION_TO_LEVEL[positionId] || DEFAULT_PERMISSION_LEVEL
        Calling.create(:job => callingName, :person_id => personId, :position_id => positionId, :access_level => level)
      end
    end
  end
end






begin
  log_file = "#{UPDATEDIR}WardListImport.log"
  puts "Logging to #{log_file}"
  $stdout = File.open(log_file,'a')
  puts Time.now.strftime("%a %b %d %Y - %I:%M %p")

  downLoadNewInfo

  # This is a flag to determine if I need to clear the cache or not for the ward 
  # list index page.
  changesMade = false

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

  jsonString = File.open("#{UPDATEDIR}WardList.json", "r").read
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
        changesMade = true

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
        person = Person.where(:uid => new.uid).first
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
          Person.create({
            :name => new.name,
            :email => new.email,
            :family_id => family.id,
            :uid => new.uid,
            :current => true
          })
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
        changesMade = true
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

      family = Family.create(:name => lastName, :head_of_house_hold => headOfHouseHold,
                             :phone => phone, :address => address, :status => "new", 
                             :uid => uid, :current => true)
      family.events.create(:date => Date.today, 
                           :category => "MoveIn",
                           :comment => "Received records from SLC")
      changesMade = true

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
        Person.create({
          :name => person.name,
          :email => person.email,
          :family_id => family.id,
          :uid => person.uid,
          :current => true
        })
      }

    end
  end

  # Get all of the non-current families. 
  # Find all that don't have a status of "Moved - Old Record" and print those to a report
  # change status of those families to   "Moved - Old Record"
  moved = Family.where({current: false, member: true}).where("status != 'Moved - Old Record'")

  unless moved.empty? 
    puts "\tFamilies moved out:"
    moved.each do |family|
      puts "\t\t" + family.name + "," + family.head_of_house_hold
      family.status = "Moved - Old Record"
      family.events.create(:date => Date.today,
                           :category => "MoveOut",
                           :comment => "Records removed from the Ward")
      # make all of the family members not current
      Person.update_all({:current => false}, {:family_id => family.id})
      family.save
      changesMade = true
    end
  end

  puts "\n"

  parse_callings

  #email_out_standing_todo
  #email_home_teachers_daily_events

  #quartlyReport

  # Clear the cache if any updates are made.
  if changesMade
    # TODO It would be great if this cron didn't have permission to just delete stuff out of our directory
    system("rm -rf #{Rails.root}/public/cache/views/*")
  end
  puts "Finished update at #{Time.now}"

rescue Exception => e
  puts "We had a failure. Printing error: "
  p e
  p e.backtrace
end
