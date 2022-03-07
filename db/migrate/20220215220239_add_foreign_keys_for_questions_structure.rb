class AddForeignKeysForQuestionsStructure < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :subthread_id, :integer
    add_foreign_key :questions, :subthreads, column: :subthread_id, primary_key: :id

    add_column :subthreads, :mr_thread_id, :integer
    add_foreign_key :subthreads, :mr_threads, column: :mr_thread_id, primary_key: :id

    add_column :mr_threads, :assessment_id, :integer
    add_foreign_key :mr_threads, :assessments, column: :assessment_id, primary_key: :id
  end
end
