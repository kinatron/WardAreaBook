task :migrate_callings => :environment do
  # Needs Confirmation
  # HP secretary => 136?

  # Currently Unused Numbers
  # SS 1st counselor => 205
  # SS 2nd counselor => 206

  POSITION_TO_LEVEL = {
    "4" => 4, # Bishop
    "54" => 4, # 1st counselor
    "55" => 4, # 2nd counselor
    "56" => 4, # Exec Sec
    "57" => 4, # Ward Clerk
    "143" => 3, # RS Pres
    "133" => 3, # HPGL
    "138" => 3, # EQP
    "221" => 3, # Ward Mission Leader
    "210" => 3, # Primary Pres
    "183" => 3, # YW Pres
    "158" => 3, # YM Pres
    "204" => 3, # SS Pres
    "134" => 2, # HP 1st assistant
    "135" => 2, # HP 2nd assistant
    "139" => 2, # EQ 1st counselor
    "140" => 2, # EQ 2nd counselor
    "141" => 2, # EQ secretary
    "144" => 2, # RS 1st counselor
    "145" => 2, # RS 2nd counselor
    "146" => 2, # RS secretary
    "151" => 2, # RS VT coordinator
    "159" => 2, # YM 1st counselor
    "160" => 2, # YM 2nd counselor
    "184" => 2, # YW 1st counselor
    "185" => 2, # YW 2nd counselor
    "211" => 2, # Primary 1st counselor
    "212" => 2, # Primary 2nd counselor
    "1395" => 2, # HP HT Supervisor
  }

  DEFAULT_PERMISSION_LEVEL = 1
  Calling.all.each do |calling|
    calling.access_level = POSITION_TO_LEVEL[calling.position_id]
    if calling.access_level.nil?
      calling.access_level = DEFAULT_PERMISSION_LEVEL
    end
    calling.save
  end
end
