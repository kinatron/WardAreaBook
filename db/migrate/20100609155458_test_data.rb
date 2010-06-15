class TestData < ActiveRecord::Migration
  def self.up
    down
    Family.create(:name => "Clark", :head_of_house_hold => "Ted and Nancy",
                  :phone => "206-854-5598", :address => "1505 Westbridge Dr, Burien WA 98146",
                  :status => "active", :information => "They have lived in the Ward for about five years. \
                  Sister Clark is in the relief society and Brother Clark is the ward mission leader")
    Family.create(:name => "Smiths", :head_of_house_hold => "Matthew John and Marnie ",
                  :phone => "253-432-5567", :address => "14171 Military Rd S",
                  :status => "active", :information => "President Smith is the Elders Quorum President")
    Family.create(:name => "Easton ", :head_of_house_hold => "Todd and Laura ",
                  :phone => "453-442-6678", :address => "17279 Military Rd N, Apt.903 ",
                  :status => "active", :information => "Brother Easton is the in Young Mens Presidency")
    Family.create(:name => "Heart", :head_of_house_hold => "Trever Lewis ",
                  :phone => "", :address => "801 Sw 123rd St ",
                  :status => "dnc", :information => "01/21/10 - Elders visited Briefly with Brother Baker. He was Cordial. 4/28/2010 b/s Hope left a note on his door.5/18/2010 Not friendly, does not want any church visitors.  Said to have Bishop send a letter to remove his name  - Elder Hope ")
    Family.create(:name => "Thurber", :head_of_house_hold => "Jerry Warth ",
                  :phone => "226-646-7822", :address => "5720 S 198th St ",
                  :status => "dnc", :information => "4/24/2010 b/s Hope left note on door. 4/28 b/s Hope went again, woman would not answer the door.5/12/2010 no one home. Phone disconnected. 5/22/2010 He has told many people he is not a member of the church.  We told him we are missionaries out to meet the different members of the ward.  \"I don't mean to be rude, but I am not a member of the ward:  Elder Hope, \"Sir if your name is on the membership list, people will be by to check on you.  Unless you write a letter asking for name to be removed.  Or speak to the Bishop\"  Mr Bigler \"I'm not a member\" and he shut the door.")
    Family.create(:name => "Barris", :head_of_house_hold => "Mik and Leiah Jean",
                  :phone => "239-263-33321", :address => "918 Sw 132nd St",
                  :status => "less active", :information => "20-yr-old granddaughter (very nice )raised by them still lives with them. She works and goes to college. (N/M)4/29/2010 b/s Hope went by to visit. They were on their way out to a doctor's appointment. Donna said to call to make a return appointment (5/18) Donald said to call some other time for an appointment")
    WardRepresentative.create(:name => "The Hopes", :type => "Full Time Missionaries")
    WardRepresentative.create(:name => "The Elders", :type => "Full Time Missionaries")
    WardRepresentative.create(:name => "Brother Clark", :type => "Ward Member")
    Event.create(:date => Date.today, :type => "Stopped By", :family_id =>4, :ward_representative_id => 2, :comment => "Stopped by the house no one was home")
    Event.create(:date => Date.yesterday, :type => "Visit", :family_id =>1, :ward_representative_id => 1, :comment => "Stopped by and shared a member lesson visit.  Clarks are working with their neighbors Ned an Kirsten and Chip and Wendy")
    Event.create(:date => Date.today, :type => "Visit", :family_id =>1, :ward_representative_id => 1, :comment => "The Clarks invited their neighbors over for a BBQ.")

  end


  def self.down
  end
end
