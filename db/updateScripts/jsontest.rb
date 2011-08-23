#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'rake'
require 'json'

class JsonPerson
  attr_accessor :name, :email, :uid
  def initialize(person)
    @name,@uid,@email = person['preferredName'],person['individualId'],person['email']
 #   puts "\t#{name} \t#{id} \t#{email}"
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

  jsonString = File.open("./31089", "r").read
  ward = JSON.parse(jsonString)
  ward.each do |family|
    uid   = family['headOfHouseIndividualId']
    coupleName = family['coupleName']
    lastName, headOfHouseHold = coupleName.split(/,/)
    lastName.strip!
    headOfHouseHold.strip!
    headOfHouseHold.gsub!("&", "and")
    address    = family['desc1'] + " " + family['desc2']
    phone      = family['phone']
    lastName ||= "" 
    headOfHouseHold ||= "" 
    phone ||= "" 
    address ||= "" 

    puts coupleName
    getFamilyMembers(family).each do | member|
    puts "\t#{member.name} \t#{member.uid} \t#{member.email}"
    end
  end
