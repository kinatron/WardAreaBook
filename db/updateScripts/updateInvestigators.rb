#!/usr/bin/env ruby
require 'rubygems'
# load the rails environment
require File.dirname(__FILE__) + "./../config/environment"

Family.find_all_by_member(false).each do | family | 
  family.current = true
  family.save
end

