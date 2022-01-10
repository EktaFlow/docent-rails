class Assessment < ApplicationRecord
  belongs_to :user
  has_many :questions

  has_many :team_members
  has_many :users, through: :team_members
end
