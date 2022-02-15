class AddRoleToTeamMember < ActiveRecord::Migration[7.0]
  def change
    add_column :team_members, :role, :string
  end
end
