#!/usr/bin/env ruby
require 'rubygems'
require 'rake'

# load the rails environment
require File.dirname(__FILE__) + "/../../config/environment"

puts Family.update_all("status = 'active'", "status = 'Active'")
puts Family.update_all("status = 'new'", "status = 'New'")
puts Family.update_all("status = 'unknown'", "status = 'Unknown - '")
puts Family.update_all("status = 'less active'", "status = 'Less Active'")
puts Family.update_all("status = 'not interested'", "status = 'Not Interested'")
