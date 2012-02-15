#!/usr/bin/env ruby
require 'rubygems'
require 'sqlite3'
require 'date'
require 'rake'
require 'json'

# load the rails environment
require File.dirname(__FILE__) + "/../../config/environment"

def handleExceptions
  # manual hacks
  # Exceptions
  # Poli Tupou
  # Conn
  # Linville
  # Place
  # Voellger

  # vil
  fam = Family.find(208)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "5822997100"
  fam.save

  # poli
  fam = Family.find(390)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "3795576311"
  fam.save

  # Conn, melani
  fam = Family.find(43)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "2731979158"
  fam.save

  # Conn, sheri
  fam = Family.find(44)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "2731980141"
  fam.save

  # Linville Craig
  fam = Family.find(308)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "2727839745"
  fam.save

  # Linville Harvey
  fam = Family.find(128)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "1615060153"
  fam.save

  # Anthony Place
  fam = Family.find(172)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "1565051994"
  fam.save

  # Shirley
  fam = Family.find(252)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "1565051011"
  fam.save

  # Tammy
  fam = Family.find(286)
#  puts "#{fam.head_of_house_hold} #{fam.name}"
  fam.uid = "1566783057"
  fam.save

  # TODO the voellgers have 3 entries find out the correct one.
  #fam = Family.find()
  #fam.uid = "xxxx"

end

def familyLookup(family)
  coupleName = family['coupleName']
  lastName, headOfHouseHold = coupleName.split(/,/)
  lastName.strip!
  headOfHouseHold.strip!
  headOfHouseHold.gsub!("&", "and")

  address    = family['desc1'] + " " + family['desc2']
  phone      = family['phone']

  lookup = Family.find(:first, 
                       :conditions => ["UPPER(name)= ? and UPPER(head_of_house_hold) = ?", 
                         lastName.upcase, headOfHouseHold.upcase])
  if lookup 
    #    puts "Found ==> #{headOfHouseHold} #{lastName}"
    return lookup
  else
    #puts "Didn't find ==> #{headOfHouseHold} #{lastName}"

    # Users may update their preferred name, so check for slight variations
    familyList =  Family.find_all_by_name(lastName)

    # if there is a common name between the new headOfHouseHold and the 
    # existing one then the head of household names have changed and it 
    # will not be interpreted as a new family
    # Jeff --> Jeff and Tanya
    # Michael Vern and Stacy - Mike and Stacy
    # William and Debbie --> Bill and Debbie
    familyId = 0
    familyList.each do |fam|
      currentNames = fam.head_of_house_hold.upcase.split.to_set
      currentNames.delete("AND")
      currentNames.delete("&")
      newNames = headOfHouseHold.upcase.split.to_set
      newNames.delete("AND")
      newNames.delete("&")
      result = currentNames & newNames
      if result.size > 0 
        #puts "#{fam.head_of_house_hold} #{fam.name} --> #{headOfHouseHold} #{lastName}"
        return fam
      end

      # Check for existing phone numbers 
      if fam.phone == phone and phone != ""
        #puts "phone !!!!! #{fam.head_of_house_hold} #{fam.name}--> #{headOfHouseHold} #{lastName}"
        return fam
      end

      # Check for existing addresses.
      if fam.address == address and address != ""
        #puts "Address ##### #{fam.head_of_house_hold} #{fam.name} --> #{headOfHouseHold} #{lastName}"
        return fam
      end
    end
    return nil
  end
end

found = 0
notFound = 0
jsonString = File.open("./31089", "r").read
ward = JSON.parse(jsonString)
ward.each do |family|
  familyId   = family['headOfHouseIndividualId']
  coupleName = family['coupleName']
  lastName, headOfHouseHold = coupleName.split(/,/)
  lastName.strip!
  headOfHouseHold.strip!
  headOfHouseHold.gsub!("&", "and")
  address    = family['desc1'] + " " + family['desc2']
  phone      = family['phone']

  fam = familyLookup(family)
  if fam
    found += 1
    fam.uid = familyId
    fam.save
  else
    # Create the new family.
    notFound += 1
  end
end

handleExceptions


puts "\n"
puts "found = #{found}"
puts "not found = #{notFound}"


