class TeamMember < ApplicationRecord
  belongs_to :user
  belongs_to :assessment
end
