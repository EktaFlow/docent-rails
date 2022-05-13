class CreateFileAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :file_attachments do |t|
      t.integer :assessment_id
      t.string :file_name
      t.timestamps
    end
  end
end
