class AddForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :assessment_id, :integer
    add_foreign_key :questions, :assessments, column: :assessment_id, primary_key: :id

    add_column :answers, :question_id, :integer
    add_foreign_key :answers, :questions, column: :question_id, primary_key: :id
  end
end
