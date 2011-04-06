class UserSession < Authlogic::Session::Base
  validate :check_if_verified

  private

  def check_if_verified
    if attempted_record and attempted_record.verified == false
      errors.add(:base, "You have not yet verified your account. \
                 Please reference your email for instructions") 
    end
  end
end
