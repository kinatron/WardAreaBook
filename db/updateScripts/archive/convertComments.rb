#!/usr/bin/env ruby
require 'rubygems'
require 'rake'

# load the rails environment
require File.dirname(__FILE__) + "/../../config/environment"

Family.all.each do |fam|
  if fam.information != nil and fam.information != ""
    Comment.create(:family_id => fam.id, :text => fam.information)
  end
end

