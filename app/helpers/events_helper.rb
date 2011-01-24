module EventsHelper
  def eventCategories 
    [
      ["Visit"  , "Visit"], 
      ["Lesson" , "Lesson"], 
      ["Attempt", "Attempt"],
      ["Other", "Other"]
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
      ["Baptized" , "Baptized"],
      ["Other", "Other"]
    ]
  end
end
