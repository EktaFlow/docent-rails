class FileAttachment < ApplicationRecord
  belongs_to :assessment
  has_many :file_attachment_answers, dependent: :destroy
  has_one_attached :outside_file
  has_many :questions, through: :file_attachment_answers
end
