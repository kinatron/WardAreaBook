# encoding: utf-8

#################
# This file will be overwritten by the CloudFormation template to contain the parameters for
# the CloudFormation template. This file is here only as an example
#################


# Backup Generated: app_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t app_backup [-c <path_to_configuration_file>]
#
Backup::Model.new(:app_backup, 'Backup the database contents of the application to S3') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = "my_database_name"
    db.username           = "my_username"
    db.password           = "my_password"
    db.host               = "localhost"
    db.port               = 3306
    db.socket             = "/tmp/mysql.sock"
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    db.skip_tables        = ["skip", "these", "tables"]
    db.only_tables        = ["only", "these" "tables"]
    db.additional_options = ["--quick", "--single-transaction"]
    # Optional: Use to set the location of this utility
    #   if it cannot be found by name in your $PATH
    # db.mysqldump_utility = "/opt/local/bin/mysqldump"
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  # Available Regions:
  #
  #  - ap-northeast-1
  #  - ap-southeast-1
  #  - eu-west-1
  #  - us-east-1
  #  - us-west-1
  #
  store_with S3 do |s3|
    s3.access_key_id     = "my_access_key_id"
    s3.secret_access_key = "my_secret_access_key"
    s3.region            = "us-east-1"
    s3.bucket            = "bucket-name"
    s3.path              = "/path/to/my/backups"
    s3.keep              = 10
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

end
