class AddInAssessmentToSubthreads < ActiveRecord::Migration[7.0]
  def change
    add_column :subthreads, :in_assessment, :boolean
  end
end
