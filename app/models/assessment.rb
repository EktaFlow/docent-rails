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

    @length = ApplicationController.helpers.grab_length(self)
    @count = ApplicationController.helpers.grab_count(@length)

    group = {
      assessment: {
        id: self.id,
        name: self.name,
        scope: self.scope,
        target_mrl: self.target_mrl,
        current_mrl: self.current_mrl,
        level_switching: self.level_switching,
        target: self.target,
        location: self.location,
        deskbook_version: self.deskbook_version,
        created_at: self.created_at,
        count: @count[0],
        length: @count[1]
      },
      team_members: @team_members
    }


    #eventually we will grab question completion
    #assessment.questions.select {|q| q.mrl == assessment.current_mrl}.length
    #assessment.questions.select { |q| q.answers.length != 0 }.length

    return group

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
