class AuthMailer < ActionMailer::Base
  default_url_options[:host] = "wardareabook.org"  

  default :from => "wardareabook@burienwardmission.com"

  def password_reset_instructions(user)  
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)  
    mail(:to => user.email, :subject => "Password Reset Instructions")
  end  

  def verification_instructions(user)  
    @activation_url = activation_url(user.perishable_token)
    mail(:to => user.email, :subject => "Ward Areabook Account verification Instructions")
  end  

end
