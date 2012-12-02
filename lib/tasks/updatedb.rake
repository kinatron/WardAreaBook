task :update_ward_db => :environment do
  require "#{Rails.root}/db/updateScripts/updateDatabase"
end
