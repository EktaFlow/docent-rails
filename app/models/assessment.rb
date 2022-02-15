class Assessment < ApplicationRecord
  belongs_to :user
  # has_many :questions
  has_many :mr_threads

  has_many :team_members
  has_many :users, through: :team_members

  def get_info_for_dashboard
    #grab team members for assessment
    @team_members = []
    self.team_members.each do |tm|
      #grab team members emails
      @team_members << {email: User.find(tm.user_id).email, role: tm.role}
    end

    #eventually we will grab question completion
    #assessment.questions.select {|q| q.mrl == assessment.current_mrl}.length
    #assessment.questions.select { |q| q.answers.length != 0 }.length

    return {
      assessment: self,
      team_members: @team_members
    }

  end

  def get_qset
    return self.questions.select {|q| q.mrl === self.current_mrl}
  end

end
