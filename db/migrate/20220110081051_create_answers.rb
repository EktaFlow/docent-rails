class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.string :answer
      t.integer :likelihood
      t.integer :consequence
      t.string :risk_response
      t.string :greatest_impact
      t.string :mmp_summary
      t.string :objective_evidence
      t.string :assumptions_yes
      t.string :notes_yes
      t.string :what
      t.string :when
      t.string :who
      t.string :risk
      t.string :reason
      t.string :assumptions_no
      t.string :documentation_no
      t.string :assumptions_na
      t.string :assumptions_skipped
      t.string :notes_skipped
      t.string :notes_no
      t.string :notes_na
      
      t.timestamps
    end
  end
end
