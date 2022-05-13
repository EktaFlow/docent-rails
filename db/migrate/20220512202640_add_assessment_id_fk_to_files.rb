class AddAssessmentIdFkToFiles < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :file_attachments, :assessments, column: :assessment_id, primary_key: :id
  end
end
