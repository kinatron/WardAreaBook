class AddUid < ActiveRecord::Migration
  def self.up
    add_column :families, :uid, :string
  end

  def self.down
    remove_column :families, :uid
  end
end
