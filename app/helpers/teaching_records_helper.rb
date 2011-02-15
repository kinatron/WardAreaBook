module TeachingRecordsHelper

  def getLessonsTaught(family)
    lessons = Array.new
    family.events.each do |event| 
      type = event.category
      if type =~ /Lesson\d/
        lessons << type.match(/\d/)[0]
      end
    end
    lessons.sort.to_sentence(:two_words_connector => ", ",
                             :last_word_connector => ", ")
  end

  def getTeachingRecordStatus(teaching_record) 
    if teaching_record.category == nil or teaching_record.category == ""
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
      ["Young Womens" , "Young Womens"],
      ["Primary" , "Primary"]
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

  def lessons
    [
      ['Lesson1', 'Message of the Restoration'],
      ['Lesson2', 'Plan of Salvation'],
      ['Lesson3', 'Gospel of Jesus Christ'],
      ['Lesson4', 'Commandments'],
      ['Lesson5', 'Laws and Ordinances'],
    ]
  end

  def teachingRecordEvents 
    [ 
      ["Visit" , "Visit"],
      ["Attempt" , "Attempt"],
      ["Lesson"  , "Lesson"],
      ["Lesson1" , "Lesson1"], 
      ["Lesson2" , "Lesson2"], 
      ["Lesson3" , "Lesson3"], 
      ["Lesson4" , "Lesson4"], 
      ["Lesson5" , "Lesson5"], 
      ["Attend Church" , "Attend Church"],
      ["Other", "Other"],
    ]
  end

  def memberMilestones  
    [
      ["Baptized" , "Baptized"],
      ["Interview with the Bishop" , "Interview with the Bishop"],
      ["Priesthood Ordiniation" , "Priesthood Ordiniation"],
      ["Attending Gospel Prin" , "Attending Gospel Prin"],
      ["Begin new member lessons" , "Begin new member lessons"],
      ["Has been given a calling" , "Has been given a calling"],
      ["Regular Sacrament Attendance" , "Regular Sacrament Attendance"],
      ["Started Family Group Sheet" , "Started Family Group Sheet"],
      ["Melchizedek Priesthood" , "Melchizedek Priesthood"],
      ["Temple Baptism Trip" , "Temple Baptism Trip"],
      ["Patriarchal Blessing" , "Patriarchal Blessing"],
      ["Temple Prep Class" , "Temple Prep Class"],
      ["Endowed" , "Endowed"],
      ["Family Sealed in the Temple" , "Family Sealed in the Temple"]
    ]
  end
end
