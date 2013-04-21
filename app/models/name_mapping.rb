class NameMapping < ActiveRecord::Base
    attr_accessible :name, :person_id, :category, :family_id
end
