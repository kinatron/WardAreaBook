#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'date'
require 'rake'
require 'vpim/vcard'

  # load the rails environment
  require File.dirname(__FILE__) + "/../../config/environment"

  agent = WWW::Mechanize.new
  puts "accessing http://lds.org"
  agent.get('http://lds.org/') do |page|
    # TODO find out if there is way to search for the links 
    # based on a regex instead of having to cycle through the links
    page.links.each do |link|
      if link.text =~ /Stake and Ward/
        page = link.click
        break
      end
    end
    form = page.form('loginForm')
    # TODO grab this from the database
    root_admin = RootAdmin.find(:first)
    form.username = root.lds_user_name
    form.password = root.lds_password
    page = agent.submit(form)
    puts "Just logged in"
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
