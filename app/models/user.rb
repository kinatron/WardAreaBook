require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :person;
  validate :valid_email


  acts_as_authentic do |c|
    c.transition_from_crypto_providers(MyCryptoProvider)
    c.logged_in_timeout = 60.minutes
  end  


  def valid_email
    person = Person.find_by_email(email)
    if person.nil?
      errors.add(:email, " - You must be a member of this ward
                             and have an email registered with lds.org
                             Please contact Brother Kinateder for more information")
    else
      self.person = person
    end
  end

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    AuthMailer.deliver_password_reset_instructions(self)  
  end  
=begin
  # code before authlogic
  #validates_presence_of      :email
  #validates_uniqueness_of    :email

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  validate :password_non_blank, :valid_email

  def before_save
    #self.email.downcase!
  end

  def self.authenticate(email, password)
    user = self.find_by_name(email.downcase)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end


  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end



private 

  def valid_email
    if Person.find_all_by_email(email).empty? 
      errors.add(:email, " - You must be a member of this ward
                             and have an email registered with lds.org
                             Please contact Brother Kinateder for more information")
    end
  end

  def password_non_blank
    errors.add(:password, " - Missing password") if hashed_password.blank?
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "shark" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

=end

end
