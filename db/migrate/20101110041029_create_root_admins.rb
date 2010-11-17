class CreateRootAdmins < ActiveRecord::Migration
  def self.up
    create_table :root_admins do |t|
      t.integer :person_id
      t.string :lds_user_name
      t.string :lds_password

      t.timestamps
    end
  end

  def self.down
    drop_table :root_admins
  end
end
