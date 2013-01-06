class HomeTeachingFile < ActiveRecord::Base

  def self.save(upload)
    name =  upload['datafile'].original_filename
    # TODO Do we really want to put these in the public folder? This means that even people
    # who aren't logged in can download the files
    directory = Rails.root.join('public', 'data')
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    path
  end
end
