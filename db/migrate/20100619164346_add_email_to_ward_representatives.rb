class AddEmailToWardRepresentatives < ActiveRecord::Migration
  def self.up
    add_column :ward_representatives, :email, :string
  end

  def self.down
    remove_column :ward_representatives, :email
  end
end
