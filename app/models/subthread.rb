class Subthread < ApplicationRecord
  belongs_to :mr_thread
  has_many :questions
end
