module FamiliesHelper
  def statusColor(status)
    case status
      when /dnc/i          ; "maroon"
      when /less active/i  ; "cyan"
      when /active/i       ; "#00ff00"
      when /mailing/i       ; "#B88A00"
      when /not interested/i ; "#B88A00"
      when /moved/i          ; "red"
      else ; "yellow"
    end
  end


  def getLastVisitDateSortable(family)
    if family.events.first != nil
      date = family.events.first.date 
      date.strftime("%Y%m%d000000")
    else
      ""
    end
  end

  def getLastVisitDate(family)
    if family.events.first != nil
      family.events.first.date 
    else
      ""
    end
  end

  def getLastVisitComment(family)
    if family.events.first != nil
      truncate(family.events.first.comment, :length => 30) 
    else
      ""
    end
  end
end
