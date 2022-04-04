class Assessment < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  # has_many :questions
  has_many :mr_threads, dependent: :destroy

  has_many :team_members, dependent: :destroy
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

  def list_of_threads
    @threads = self.mr_threads.select {|th| th.mr_level == self.current_mrl}
    @as = []
    @threads.each do |th|
      h = {
        id: th.id,
        name: th.name,
        subthreads: []
      }
      th.subthreads.each do |sth|
        s = {
          id: sth.id,
          name: sth.name
        }
        h.subthreads << s
      end
      @as << h
    end
    return @as
  end

  def find_current_question
    @all_qs = helpers.grab_length
    @question = @all_qs.find {|q| q.answered == false}
  end


end
