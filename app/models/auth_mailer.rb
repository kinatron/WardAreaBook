class AuthMailer < ActionMailer::Base
  default_url_options[:host] = "wardareabook.org"  

  def password_reset_instructions(user)  
    subject       "Password Reset Instructions"  
    from          "Ward Areabook"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
  end  

  def verification_instructions(user)  
    subject       "Ward Areabook Account verification Instructions"  
    from          "Ward Areabook"  
    recipients    user.email  
    sent_on       Time.now  
    body          :activation_url => activation_url(user.perishable_token)  
  end  

end
