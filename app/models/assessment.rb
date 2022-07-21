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
      tm_u = User.find(tm.user_id)
      @team_members << {name: tm_u.name, email: tm_u.email, role: tm.role}
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
      # binding.pry
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
    @question = @all_qs.find {|q| q.answered == nil || q.answered == false}
  end

  def get_files_for_explorer
    @files = []
    if self.file_attachments.length > 0
      self.file_attachments.each do |fa|
        f = {
          id: fa.id,
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
          criteria_text: sth.criteria_text,
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

  def switch_level(cq, movement)
    #if target mrl == 4 and we've dropped down 1 level (failed for the first time)
    #finding the right question to switch to
    thread_start = cq.subthread.mr_thread.name[0]
    #thread_start could equal 'A' || 'B' || 'C'
    #the current_mrl is updated to the new number (this would equal mrl 3)
    ths = MrThread.where(mr_level: self.current_mrl)
    #[<MrThread mrl: 3 name: 'A: Technology ..'>, <MrThread mrl: 3, name: 'B: Design'>, <MrThread mrl: 3, name: 'C: ...'>,  ...]
    #this is grabbing the correct thread out of those
    #this sorts through that list and matches the starting letter from the name
    #string in rails, you can get any character
    #str = 'Docent' ... str[0] == 'D' ; str[3] == 'e'

    th = ths.select {|th| th.name[0] == thread_start}[0]
    #this should give us the correct dropped thread

    if movement == 'forward'
        #either this finds the next dropped subthread for us OR if we have passed the subthread (based on the subthread status + whatever the current_mrl is set to (which we do before we enter this function))
        # self.update(dropped_subthread_id: sth.id)
        #subthread.name == 'A.1'
        if self.current_mrl != self.target_mrl
          subthread_start = cq.subthread.name[0..2]
          #from the new thread, we look through all the subthreads and find the first question out of the correct subthread
          subs = th.subthreads.select { |sth| sth.questions.length > 0 }
          #subs == [<Subthread name: 'A.1: Technology ..'>, <Subthread name: 'A.2: Design'>]
          sth = subs.select {|st| st.name[0..2] == subthread_start}[0]
          if sth
            # binding.pry
            #if we have found the right subthread in the right thread (after dropping down a level), return the first question of that subthread
            return sth.questions[0]
          end
        else
          #if target mrl && current mrl match, means we are BACK in the right MRL and we need to navigate to the next subthread
          index_of_thread = ths.find_index(th)
          subthread_start = cq.subthread.name[0..2]
          #if we fail A.1 level 4, then PASS A.1 level 3 -- we should just move to A.2 level 4
          #later on, if we fail B.2 level 4, pass B.2 level 3 -- we will need to move to C.1 level 4
          subs = th.subthreads.select { |sth| sth.questions.length > 0 }
          sth = subs.select {|st| st.name[0..2] == subthread_start}[0]
          #if our subthread is the LAST in the thread
          if subs.find_index(sth) == subs.length - 1
            #jump to next thread A.2 --> B.1
            new_thread = ths[index_of_thread + 1]
            #this will make sure we don't have any empty subthreads (precaution)
            new_thread_subthreads = new_thread.subthreads..select { |sth| sth.questions.length > 0 }
            #then grab first question from first subthread
            return new_thread_subthreads[0].questions[0]
          else
            #if its not the last subthread in the thread
            #A.1 --> A.2
            subthread_index = subs.find_index(sth)
            next_subthread = subs[subthread_index + 1]
            return next_subthread.questions[0]
          end
        end
    elsif movement == 'backwards'
      # binding.pry
      #is the current subthread you're in, the first one of the dropped MrThread
      #MrThread A level 3 :: A.1, A.2
      subthread_start = cq.subthread.name[0..2]
      sth = subs.select {|st| st.name[0..2] == subthread_start}[0]
      if th.subthreads.first != sth
        #this needs the same build out if we're switching threads (and not just subthreads, because right now we're not even checking for that)
        #finds the index of the current dropped MrThread
        #most likely the issue spot? i can't remember what this is exactly supposed to do
        subthread_index = subs.find_index(sth)
        prev_subthread = subs[subthread_index - 1]
        return prev_subthread.questions[0]
        # index = ths.find_index(th)
        # if index != 0
        #   @new_th = ths[index - 1]
        #   # binding.pry
        #   subs = @new_th.subthreads.select { |sth| sth.questions.length > 0 }
        #   return subs.last.questions.last
        # end
      else
        #if the subthread is the first one
        #we'll need to drop down to the next subthread
        index_of_thread = ths.find_index(th)
        new_thread = ths[index_of_thread - 1]
        new_thread_subthreads = new_thread.subthreads..select { |sth| sth.questions.length > 0 }
        #then grab last question from last subthread of the new thread
        return new_thread_subthreads.last.questions.last
      end
    end
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
    cu = qs.select {|q| q.answered != nil} #finds and returns all questions that are answered
    cu_i = qs.find_index(cu) #finds index of 
    if cu_i
      cuu = (cu_i.to_i - 1)
    else
      cuu = 0
    end
    return [cu.length, qs.length]
  end


end
