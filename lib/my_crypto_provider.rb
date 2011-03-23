class MyCryptoProvider
  def self.encrypt(*tokens)
    password = tokens[0]
    salt = tokens[1]
    string_to_hash = password + "shark" + salt
    digest = Digest::SHA1.hexdigest(string_to_hash)
  end

  def self.matches?(crypted, *tokens)
    # return true if the tokens match the crypted_password
    crypted == self.encrypt(*tokens)
  end
  
end
