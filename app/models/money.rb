class Money < ActiveRecord::Base
  self.table_name = 'money'
  COINTS = [ 1, 2, 5, 10, 25, 50 ]

  validates :quantity, :sum_of_coint, presence: true
  validates :sum_of_coint, uniqueness: true

  validates :sum_of_coint, inclusion: COINTS

end