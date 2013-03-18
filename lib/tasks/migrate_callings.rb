task :migrate_callings => :environment do
  report_only = ['134', '135', '1395', '139', '140', '141', '144', '145', '146', '151' ]
  Calling.each do |calling|
    if report_only.include? calling.position_id
      calling.access_level = 2
    elsif calling.access_level > 1
      calling.access_level += 1
    end
    calling.save
  end
end
