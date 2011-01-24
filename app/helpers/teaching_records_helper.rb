module TeachingRecordsHelper

  def getTeachingRecordStatus(teaching_record) 
    if teaching_record.category == nil
      return teaching_record.family.status
    else
      return teaching_record.category
    end
  end

  def wardOrganizations
    [
      ["Ward Mission"  , "Ward Mission"], 
      ["Elders Quorum" , "Elders Quorum"], 
      ["High Priests"  , "High Priests"], 
      ["Young Mens" , "Young Mens"], 
      ["Relief Society" , "Relief Society"],
    ]
  end

  def teachingRecordStatus
    [
      ["Investigator"  , "Investigator"], 
      ["Recent Convert", "Recent Convert"], 
      ["Less Active"   , "Less Active"], 
      ["Active"        , "Active"], 
      ["Part Member"   , "Part Member"], 
      ["Focus Family"  , "Focus Family"],
    ]
  end

  def memberMilestoneCategories  
    [
      ["Baptism" , "Baptism"],
      ["Interview with the Bishop" , "Interview with the Bishop"],
      ["Priesthood Ordiniation" , "Priesthood Ordiniation"],
      ["Attending Gospel Prin" , "Attending Gospel Prin"],
      ["Begin new memeber lessons" , "Begun new memeber lessons"],
      ["Has been given a calling" , "Has been given a calling"],
      ["Regular Sacrement Attendance" , "Regular Sacrement Attendance"],
      ["Started Family Group Sheet" , "Started Family Group Sheet"],
      ["Melchizedek Priesthood" , "Melchizedek Priesthood"],
      ["Temple Baptism" , "Temple Baptism"],
      ["Temple Prep Class" , "Temple Prep Class"],
      ["Endowed" , "Endowed"],
      ["Family Sealed in the Temple" , "Family Sealed in the Temple"]
    ]
  end
end
