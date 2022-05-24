class AddStatusToSubthread < ActiveRecord::Migration[7.0]
  def change
    add_column :subthreads, :status, :string
  end
end
