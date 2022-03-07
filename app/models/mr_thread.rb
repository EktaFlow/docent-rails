class MrThread < ApplicationRecord
  belongs_to :assessment
  has_many :subthreads, dependent: :destroy
end
