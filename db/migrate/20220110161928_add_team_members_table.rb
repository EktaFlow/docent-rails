class AddTeamMembersTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :users, :assessments, table_name: :team_members
  end
end
