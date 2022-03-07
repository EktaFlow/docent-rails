class UpdateQuestionsWithNewRelations < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :thread_name
    remove_column :questions, :subthread_name
    remove_column :questions, :question_id
    remove_column :questions, :mr_level
    remove_column :questions, :assessment_id
    # add_column :questions, :subthread, foreign_key: true
    
  end
end
