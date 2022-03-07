class ChangeReferenceTextLocation < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :help_text
    remove_column :questions, :criteria_text
    add_column :subthreads, :help_text, :string
    add_column :subthreads, :criteria_text, :string
  end
end
