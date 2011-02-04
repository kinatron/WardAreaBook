module FamiliesHelper
  def statusColor(status)
    case status
      when /dnc/i            ; "maroon"
      when /less active/i    ; "cyan"
      when /missionary/i    ; "cyan"
      when /active/i         ; "#00ff00"
      when /member/i         ; "#00ff00"
      when /mailing/i        ; "#B88A00"
      when /not interested/i ; "#B88A00"
      when /moved/i          ; "red"
      when /returned/i       ; "red"
      when /request/i       ; "red"
      when /investigator/i  ; "yellow"
      when /recent convert/i       ; "yellow"
      else ; "yellow"
    end
  end

  def displayAddress(address)
    begin
      # city, state zipcode   - put a break right before the city.
      address.insert(address.rindex(/\W+\w+\W+\w+\W+\d\d\d\d\d/),"<br>")
    rescue
      address
    end
  end

  def getLastVisit(family)
    lastVisit = family.events.first(:conditions => 
                                    "category != 'Attempt' and
                                     category != 'Other' and 
                                     category is not NULL")
    end
                                     
  def getLastVisitDate(family)
    lastVisit = getLastVisit(family)
    if lastVisit != nil
      lastVisit.date.to_s(:sortable)
    else
      ""
    end
  end

  def getLastVisitDateSortable(family)
    lastVisit = getLastVisit(family)
    if lastVisit != nil
      lastVisit.date.strftime("%Y%m%d")
    else
      ""
    end
  end
    

  def getLastVisitComment(family)
    lastVisit = getLastVisit(family)
    if lastVisit != nil
      truncate(lastVisit.comment, :length => 100) 
    else
      lastContact = family.events.first
      if lastContact != nil
        truncate(lastContact.comment, :length => 100) 
      else
        ""
      end
    end
  end

  def nonmemberType
    [
      ["Missionary Find" , "Missionary Find"],
      ["Member Referral" , "Member Referral"],
      ["Self Referral"   , "Self Referral"],
      ["Part Member"     , "Part Member"],
      ["Request Records" , "Request Records"]
    ]
  end
  def memberStatus
    [
      ["active"          , "active"], 
      ["less active"     , "less active"], 
      ["moved"           , "moved"], 
      ["not interested"  , "not interested"],
      ["dnc"             , "dnc" ]
    ]
  end
end
