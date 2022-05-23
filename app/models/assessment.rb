class Assessment < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  # has_many :questions
  has_many :mr_threads, dependent: :destroy
  has_many :file_attachments, dependent: :destroy

  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  def get_info_for_dashboard(type)
    #grab team members for assessment
    @team_members = []
    self.team_members.each do |tm|
      #grab team members emails
      @team_members << {email: User.find(tm.user_id).email, role: tm.role}
    end

    @length = ApplicationController.helpers.grab_length(self)
    @count = ApplicationController.helpers.grab_count(@length)
    group = ''
    if type == 'owned'
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
          length: @count[1],
          shared: false
        },
        team_members: @team_members
      }
    else
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
          length: @count[1],
          shared: true
        },
        team_members: @team_members
      }
    end

    #eventually we will grab question completion
    #assessment.questions.select {|q| q.mrl == assessment.current_mrl}.length
    #assessment.questions.select { |q| q.answers.length != 0 }.length

    return group

  end

  def list_of_threads
    @threads = self.mr_threads.select {|th| th.mr_level == self.current_mrl}
    @as = []
    @threads.each do |th|
      thread = {
        id: th.id,
        name: th.name,
        subthreads: []
      }
      th.subthreads.each do |sth|
        if sth.questions.length != 0
          subthread = {
            id: sth.id,
            name: sth.name
          }
          thread[:subthreads] << subthread
        end
      end
      if thread[:subthreads].length != 0
        @as << thread
      end
    end
    return @as
  end

  def find_current_question
    @all_qs = ApplicationController.helpers.grab_length(self)
    @question = @all_qs.find {|q| q.answered == nil}
  end

  def get_files_for_explorer
    @files = []
    if self.file_attachments.length > 0
      self.file_attachments.each do |fa|
        f = {
          url: fa.outside_file.attachment ? fa.outside_file.attachment.blob.url : nil,
          name: fa.file_name,
          created_at: fa.created_at,
          questions: []
        }
        if fa.questions.length
          fa.questions.each do |question|
            q = {
              id: question.id,
              question_num: question.grab_location
            }
            f[:questions] << q
          end
        end
        @files << f
      end
    end
    return @files
  end

  def report_grouping
    @threads = self.mr_threads.select {|th| th.mr_level == self.current_mrl}
    @as = []
    @threads.each do |th|
      thread = {
        id: th.id,
        name: th.name,
        subthreads: []
      }
      th.subthreads.each do |sth|
        subthread = {
          id: sth.id,
          name: sth.name,
          questions: []
        }
        sth.questions.each do |q|
          question = {
            id: q.id,
            question_text: q.question_text,
            answer: q.answers.length > 0 ? q.answers.last : 'Unanswered'
          }
          subthread[:questions] << question
        end
        thread[:subthreads] << subthread
      end
      @as << thread
    end
    return @as
  end


end
