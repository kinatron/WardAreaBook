class HomeTeachingFile < ActiveRecord::Base

  def self.save(upload)
    name =  upload['datafile'].original_filename
    directory = "#{RAILS_ROOT}/public/data"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    path
  end
end
