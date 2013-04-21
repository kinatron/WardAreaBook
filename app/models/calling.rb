class Calling < ActiveRecord::Base
  has_many :calling_assignments, :dependent => :destroy
  has_many :people, :through => :calling_assignments

  attr_accessible :job, :position_id, :access_level

  WARD_COUNCIL = ['4', '54', '55', '56', '57', '143', '133', '138', '221', '210', '183', '158', '204']
  RELIEF_SOCIETY = ['143', '144', '145', '146', '151']
  ELDERS_QUORUM = ['138', '139', '140', '141']
  HIGH_PRIESTS = ['133', '134', '135', '1395']

end
