class AddAuthlogicToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :person_id,          :integer
    add_column :users, :logged_in_now,      :boolean,  :default => false
    # Authlogic types
    rename_column :users, :hashed_password, :crypted_password
    rename_column :users, :salt,            :password_salt
    rename_column :users, :name,            :email
    add_column :users, :persistence_token,  :string, :default => "", :null => false
    add_column :users, :perishable_token,   :string, :default => "", :null => false
    add_column :users, :single_access_token,:string, :default => "", :null => false

    add_column :users, :login_count,        :integer, :default => 0, :null => false
    add_column :users, :failed_login_count, :integer, :default => 0, :null => false
    add_column :users, :last_request_at,    :datetime
    add_column :users, :current_login_at,   :datetime
    add_column :users, :last_login_at,      :datetime
    remove_column :users, :last_login, :access_level
  end

  def self.down
    remove_column :users, :person_id, :persistence_token, :perishable_token, :single_access_token 
    remove_column :users, :login_count, :failed_login_count, :last_request_at, 
                           :current_login_at, :last_login_at, :logged_in_now
    add_column :users, :last_login, :date
    add_column :users, :access_level, :integer
    rename_column :users, :crypted_password, :hashed_password
    rename_column :users, :password_salt, :salt
    rename_column :users, :email, :name
  end
end
