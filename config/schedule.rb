# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
env :PATH, ENV['PATH']

every 1.day, :at => '2am' do
    command "/usr/local/bin/backup perform -t app_backup -c /var/app/wardareabook/Backup/config.rb", :output => '/tmp/backup_db.log'
end

every 1.day, :at => '3am' do
  rake 'update_ward_db', :output => '/tmp/update_ward_db.log'
end
