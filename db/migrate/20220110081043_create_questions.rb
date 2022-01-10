class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :question_text
      t.string :question_id
      t.string :current_answer
      t.boolean :skipped
      t.string :thread_name
      t.string :subthread_name
      t.integer :mr_level
      t.string :help_text
      t.string :criteria_text
      t.boolean :answered
      
      t.timestamps
    end
  end
end
