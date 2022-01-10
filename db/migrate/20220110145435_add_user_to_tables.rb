class AddUserToTables < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :owner_id, :integer
    add_foreign_key :assessments, :users, column: :owner_id, primary_key: :id

    add_column :answers, :user_id, :integer
    add_foreign_key :answers, :users, column: :user_id, primary_key: :id
  end
end
