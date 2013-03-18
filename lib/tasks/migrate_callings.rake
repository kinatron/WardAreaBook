task :migrate_callings => :environment do
  # CALLING => POSITION_ID
  # Bishop => 4
  # 1st counselor => 54
  # 2nd counselor => 55
  # Exec Sec => 56
  # Ward Clerk => 57
  # RS Pres => 143
  # RS 1st counselor => 144
  # RS 2nd counselor => 145
  # RS secretary => 146
  # RS VT coordinator => 151
  # HPGL => 133
  # HP 1st assistant => 134
  # HP 2nd assistant => 135
  # HP secretary => 136? (needs confirmation)
  # HP HT Supervisor => 1395
  # EQP => 138
  # EQ 1st counselor => 139
  # EQ 2nd counselor => 140
  # EQ secretary => 141
  # Ward Mission Leader => 221
  # Primary Pres => 210
  # Primary 1st counselor => 211
  # Primary 2nd counselor => 212
  # YW Pres => 183
  # YW 1st counselor => 184
  # YW 2nd counselor => 185
  # YM Pres => 158
  # YM 1st counselor => 159
  # YM 2nd counselor => 160
  # SS Pres => 204
  # SS 1st counselor => 205
  # SS 2nd counselor => 206
  POSITION_TO_LEVEL = {
    "4" => 4,
    "54" => 4,
    "55" => 4,
    "56" => 4,
    "57" => 4,
    "143" => 3,
    "133" => 3,
    "138" => 3,
    "221" => 3,
    "210" => 3,
    "183" => 3,
    "158" => 3,
    "204" => 3,
    "134" => 2,
    "135" => 2,
    "139" => 2,
    "140" => 2,
    "141" => 2,
    "144" => 2,
    "145" => 2,
    "146" => 2,
    "151" => 2,
    "159" => 2,
    "160" => 2,
    "184" => 2,
    "185" => 2,
    "211" => 2,
    "212" => 2,
    "1395" => 2,
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
