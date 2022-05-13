class FileAttachmentAnswer < ApplicationRecord
  belongs_to :file_attachment
  belongs_to :question
end
