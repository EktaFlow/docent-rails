class ChangeAnswerToQuestionForFileAttachmentAnswers < ActiveRecord::Migration[7.0]
  def change
    remove_column :file_attachment_answers, :answer_id
    add_column :file_attachment_answers, :question_id, :integer
    add_foreign_key :file_attachment_answers, :questions, column: :question_id, primary_key: :id
    add_foreign_key :file_attachment_answers, :file_attachments, column: :file_attachment_id, primary_key: :id
  end
end
