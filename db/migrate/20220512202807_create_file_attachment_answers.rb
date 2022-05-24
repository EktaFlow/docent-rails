class CreateFileAttachmentAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :file_attachment_answers do |t|
      t.integer :file_attachment_id
      t.integer :answer_id
      t.timestamps
    end
  end
end
