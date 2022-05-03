class Assessment < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  # has_many :questions
  has_many :mr_threads, dependent: :destroy

  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  def get_info_for_dashboard(type)
    #grab team members for assessment
    @team_members = []
    self.team_members.each do |tm|
      #grab team members emails
      @team_members << {email: User.find(tm.user_id).email, role: tm.role}
    end

    @length = self.grab_length
    @count = self.grab_count(@length)
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
    @all_qs = self.grab_length
    @question = @all_qs.find {|q| q.answered == nil}
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

  def switch_level(cq)
    thread_start = cq.subthread.mr_thread.name[0]
    ths = MrThread.where(mr_level: self.current_mrl)
    th = ths.select {|th| th.name[0] == thread_start}[0]
    subthread_start = cq.subthread.name[0..2]
    sth = th.subthreads.select {|st| st.name[0..2] == subthread_start}
    if sth
      self.update(dropped_subthread_id: sth.id)
      return sth.questions[0]
    end
  end

  def next_subthread_after_ls(cq)
    @questions = self.grab_length
  end

  #this returns an array that's all questions in assessment that match current mrl
  #make sure test assessments have current_mrl filled in
  def grab_length
    cmrl = self.current_mrl
    @th = self.mr_threads.select {|thread| thread.mr_level == cmrl}
    questions = []
    @th.each do |thread|
      thread.subthreads.each do |sth|
        sth.questions.each do |q|
          questions << q
        end
      end
    end
    return questions
  end

  def grab_count(qs)
    cu = qs.find {|q| q.answered != nil}
    cu_i = qs.find_index(cu)
    if cu_i
      cuu = (cu_i.to_i - 1)
    else
      cuu = 0
    end
    return [cuu, qs.length]
  end


end
