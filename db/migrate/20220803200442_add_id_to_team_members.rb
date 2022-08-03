class AddIdToTeamMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :team_members, :id, :primary_key
  end
end
