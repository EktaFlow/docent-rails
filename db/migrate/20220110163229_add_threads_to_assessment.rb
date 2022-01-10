class AddThreadsToAssessment < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :threads, :string, array: true, default: []
  end
end
