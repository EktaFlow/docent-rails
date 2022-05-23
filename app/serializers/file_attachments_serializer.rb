# class FileAttachmentsSerializer < ActiveModel::Serializer
#   include Rails.application.routes.url_helpers
#   attributes :id, :assessment_id, :question_id, :file_name, :outside_file

#   def outside_file 
#     rails_blob_path(object.outside_file, only_path: true) if object.outside_file.attached?
#   end
# end
