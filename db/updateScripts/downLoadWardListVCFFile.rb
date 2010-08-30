#! /usr/bin/env ruby
require 'rubygems'
  require 'mechanize'

  agent = Mechanize.new

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
    form.username = ""
    form.password = ""
    page = agent.submit(form)
    puts "Just logged in"
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
    agent.get(vcardHref).save_as("WardList.vcf")
    puts "Done"
  end
