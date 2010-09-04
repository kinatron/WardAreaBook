#!/usr/bin/env ruby
require 'rubygems'
require 'vpim/vcard'
# load the rails environment
require File.dirname(__FILE__) + "./../config/environment"

# Manually add the following.  as of Aug 27th
#
fam = Family.find_by_name("Alkire");
fam.uid = "dnp6aY6benqBeHZ6emZ/dnqg"
fam.save!

fam = Family.find_by_name_and_head_of_house_hold("Glaefke", "Jack Warren P. and Delores Gaylene")
fam.uid = "dXZ5bpCadnmGenV3boiBdXaa"
fam.save!

fam = Family.find_by_name_and_head_of_house_hold("Johnson", "John Wallis")
fam.uid = "cXJ0a4qWcnSDdHFzaYOocXKC"
fam.save!


fam = Family.find_by_name("Meraz")
fam.uid = "dnp5Z4ibenl/cnZ8fXpjdnuD"
fam.save!

fam = Family.find_by_name("Puloka") 
fam.uid = "dnZ3aY6bdneBeHZ2fqyxdnag"
fam.save!

fam = Family.find_by_name("Tipton")
fam.uid = "dnh2bJibeHaEgnZ5a4aPdnl5"
fam.save!

fam = Family.find_by_name("Hope")
fam.uid = "we love the hopes"
fam.save!

fam = Family.find_by_name("Elders")
fam.uid = "we love the Elders"
fam.save!


cards = Vpim::Vcard.decode(open("WardList.vcf"))

cards.each do |card|
  # Last name
  fam = Family.find_by_name_and_head_of_house_hold(card.name.family,card.name.given)
  if fam
    fam.uid = card.value("UID")
    fam.save!
  else 
    puts "Couldn't find " + card.name.family + " " + card.name.given
  end
end


