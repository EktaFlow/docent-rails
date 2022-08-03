class Assessment < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  # has_many :questions
  has_many :mr_threads, dependent: :destroy
  has_many :file_attachments, dependent: :destroy

  has_many :team_members
  has_many :users, through: :team_members

  def get_info_for_dashboard(type)
    #grab team members for assessment
    @team_members = []
    self.team_members.each do |tm|
      #grab team members emails
      tm_u = User.find(tm.user_id)
      @team_members << {name: tm_u.name, email: tm_u.email, role: tm.role}
    end

    @length = self.level_switching ? self.level_switch_length : self.grab_length(self.current_mrl)
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
    @all_qs = self.grab_length(self.target_mrl)
    @question = @all_qs.find {|q| q.answered == nil || q.answered == false}
    subth = self.get_correct_subthread(@question.subthread)
    # return subth.questions.first
    return @question
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

  #returns all threads, not just ones at current_mrl --> used for filtering on frontend
  def get_all_threads
    # @all_threads = Hash.new #5 => {threads}
    #get threads of assessment at each mrl
    @all_threads = []
    #only need threads up to target_mrl because will not go beyond that
    (1..self.target_mrl).each do |mrl|
      # @all_threads[mrl] = []
      @current_level_ths = self.mr_threads.select {|th| th.mr_level == mrl}
      ordered_threads = @current_level_ths.sort_by {|obj| obj.name.downcase}

      ordered_threads.each do |th|
        thread = {
          id: th.id,
          name: th.name,
          mr_level: th.mr_level, 
          subthreads: []
        }
        ordered_subthreads = th.subthreads.sort_by {|obj| obj.name.downcase}
        ordered_subthreads.each do |sth|
          subthread = {
            id: sth.id,
            name: sth.name,
            criteria_text: sth.criteria_text,
            questions: []
          }
          ordered_questions = sth.questions.sort_by{|obj| obj.id}
          ordered_questions.each do |q|
            question = {
              id: q.id,
              question_text: q.question_text,
              answer: q.answers.length > 0 ? q.answers.last : 'Unanswered'
            }
            subthread[:questions] << question
          end
          thread[:subthreads] << subthread
        end
        # @all_threads << thread #ADD @ths TO @all_threads AT MRL FOR HASH
        # @all_threads[mrl] << thread
        @all_threads << thread
      end
    end

    return @all_threads
  end

  def report_grouping
    #show all threads, not just one at current_mrl - filter on frontend?
    @threads = self.mr_threads.select {|th| th.mr_level == self.current_mrl}
    #send back all threads so users can filter as they want on frontend
    # @threads = self.mr_threads
      #NEED TO FILTER THIS
    @as = []
    ordered_threads = @threads.sort_by {|obj| obj.name.downcase}
    # binding.pry
    # self.mr_threads = ordered_threads
    ordered_threads.each do |th|
      thread = {
        id: th.id,
        name: th.name,
        mr_level: th.mr_level, 
        subthreads: []
      }
      ordered_subthreads = th.subthreads.sort_by {|obj| obj.name.downcase}
      th.subthreads = ordered_subthreads
      ordered_subthreads.each do |sth|
        subthread = {
          id: sth.id,
          name: sth.name,
          criteria_text: sth.criteria_text,
          questions: []
        }
        ordered_questions = sth.questions.sort_by{|obj| obj.id}
        sth.questions = ordered_questions
        ordered_questions.each do |q|
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

  # def switch_level(cq, movement)
  #   #if target mrl == 4 and we've dropped down 1 level (failed for the first time)
  #   #finding the right question to switch to
  #   thread_start = cq.subthread.mr_thread.name[0]
  #   #thread_start could equal 'A' || 'B' || 'C'
  #   #the current_mrl is updated to the new number (this would equal mrl 3)
  #   ths = MrThread.where(mr_level: self.current_mrl)
  #   #[<MrThread mrl: 3 name: 'A: Technology ..'>, <MrThread mrl: 3, name: 'B: Design'>, <MrThread mrl: 3, name: 'C: ...'>,  ...]
  #   #this is grabbing the correct thread out of those
  #   #this sorts through that list and matches the starting letter from the name
  #   #string in rails, you can get any character
  #   #str = 'Docent' ... str[0] == 'D' ; str[3] == 'e'

  #   th = ths.select {|th| th.name[0] == thread_start}[0]
  #   #this should give us the correct dropped thread
  #   # binding.pry
  #   if movement == 'forward'
  #       #either this finds the next dropped subthread for us OR if we have passed the subthread (based on the subthread status + whatever the current_mrl is set to (which we do before we enter this function))
  #       # self.update(dropped_subthread_id: sth.id)
  #       #subthread.name == 'A.1'
  #       # binding.pry
  #       if self.current_mrl != self.target_mrl
  #         subthread_start = cq.subthread.name[0..2]
  #         #from the new thread, we look through all the subthreads and find the first question out of the correct subthread
  #         subs = th.subthreads.select { |sth| sth.questions.length > 0 }
  #         #subs == [<Subthread name: 'A.1: Technology ..'>, <Subthread name: 'A.2: Design'>]
  #         sth = subs.select {|st| st.name[0..2] == subthread_start}[0]
  #         if sth
  #           # binding.pry
  #           #if we have found the right subthread in the right thread (after dropping down a level), return the first question of that subthread
  #           return sth.questions[0]
  #         end
  #       else
  #         #if target mrl && current mrl match, means we are BACK in the right MRL and we need to navigate to the next subthread
  #         index_of_thread = ths.find_index(th)
  #         subthread_start = cq.subthread.name[0..2]
  #         #if we fail A.1 level 4, then PASS A.1 level 3 -- we should just move to A.2 level 4
  #         #later on, if we fail B.2 level 4, pass B.2 level 3 -- we will need to move to C.1 level 4
  #         subs = th.subthreads.select { |sth| sth.questions.length > 0 }
  #         sth = subs.select {|st| st.name[0..2] == subthread_start}[0]
  #         #if our subthread is the LAST in the thread
  #         if subs.find_index(sth) == subs.length - 1
  #           #jump to next thread A.2 --> B.1
  #           new_thread = ths[index_of_thread + 1]
  #           #this will make sure we don't have any empty subthreads (precaution)
  #           new_thread_subthreads = new_thread.subthreads..select { |sth| sth.questions.length > 0 }
  #           #then grab first question from first subthread
  #           return new_thread_subthreads[0].questions[0]
  #         else
  #           #if its not the last subthread in the thread
  #           #A.1 --> A.2
  #           subthread_index = subs.find_index(sth)
  #           next_subthread = subs[subthread_index + 1]
  #           return next_subthread.questions[0]
  #         end
  #       end
  #   elsif movement == 'backwards'
  #     # binding.pry
  #     #is the current subthread you're in, the first one of the dropped MrThread
  #     #MrThread A level 3 :: A.1, A.2
  #     subthread_start = cq.subthread.name[0..2]
  #     subs = th.subthreads.select { |sth| sth.questions.length > 0 }
  #     sth = subs.select {|st| st.name[0..2] == subthread_start}[0]
  #     if th.subthreads.first != sth
  #       #this needs the same build out if we're switching threads (and not just subthreads, because right now we're not even checking for that)
  #       #finds the index of the current dropped MrThread
  #       #most likely the issue spot? i can't remember what this is exactly supposed to do
  #       subthread_index = subs.find_index(sth)
  #       prev_subthread = subs[subthread_index - 1]
  #       return prev_subthread.questions[0]
  #       # index = ths.find_index(th)
  #       # if index != 0
  #       #   @new_th = ths[index - 1]
  #       #   # binding.pry
  #       #   subs = @new_th.subthreads.select { |sth| sth.questions.length > 0 }
  #       #   return subs.last.questions.last
  #       # end
  #     else
  #       #if the subthread is the first one
  #       #we'll need to drop down to the next subthread
  #       index_of_thread = ths.find_index(th)
  #       new_thread = ths[index_of_thread - 1]
  #       new_thread_subthreads = new_thread.subthreads..select { |sth| sth.questions.length > 0 }
  #       #then grab last question from last subthread of the new thread
  #       return new_thread_subthreads.last.questions.last
  #     end
  #   end
  # end

  #returns subthread at correct mrl when level switching (when navigating or when assessment loads in)
    #pass in subthread name (A.1) and thread at current mrl to get ones lower
  #WHERE DO I CALL THIS FUNCTION???
  def get_correct_subthread(subthread)
    new_th = subthread.mr_thread
    # binding.pry
    #start at subthread at target_mrl = current_sub
    current_sub = new_th.subthreads.where(name: subthread.name)[0]
    #find sub_below
    th_below = self.mr_threads.where(name: new_th.name, mr_level: (new_th.mr_level - 1))[0]
    # binding.pry
    sub_below = th_below.subthreads.where(name: subthread.name)[0]

    #if current_sub is passed and in_assessment --> return this one
    if (current_sub.in_assessment && current_sub.status == 'passed') || (sub_below.in_assessment && sub_below.status == 'passed')
      return current_sub

    #else if current_sub in assessment and failed 
    elsif current_sub.in_assessment && current_sub.status == 'failed'
      if sub_below.in_assessment
        if sub_below.status == 'passed'
          return current_sub #if sub below is passed, stay in thread that failed

        #if sub_below failed, check if sub_below.sub_below in assessment and failed (loop)
        elsif sub_below.status == 'failed'
          #keep finding subthread below until finds one that has not failed
          while sub_below.in_assessment && sub_below.status == 'failed' 
            if new_th.mr_level != 1
              #grab new subthread at lower mrl
              new_th = self.mr_threads.where(name: new_th.name, mr_level: (new_th.mr_level - 1))[0]
              sub_below = new_th.subthreads.where(name: sub_below.name)[0]
            else  #if at mrl 1, return same subthread because can't go down anymore
              return current_sub 
            end
          end
          #update and return sub_below 
          sub_below.update(in_assessment: true)
          sub_below.save
          return sub_below
        else #if sub_below status is not set yet
          return sub_below
        end

      else #else if sub_below not already in assessment, set to true and then return sub_below
        sub_below.update(in_assessment: true)
        sub_below.save
        return sub_below
      end

    end
    return current_sub
  end

  #returns new subthread or first question in new subthread - which one would be better?  
  def swap_subthread(current_question, current_subthread, movement)
    #thread that needs to be changed
    curr_thread = current_question.subthread.mr_thread
    #get all threads in target mrl for navigating normally
    threads_in_target_mrl = self.mr_threads.where(mr_level: self.target_mrl)

    #if movement forward and failed
    if movement == 'forward' && current_subthread.status == 'failed'
      #ADD CONDITION IF GETS TO MRL 1, CAN'T GO DOWN ANYMORE
      #get subthread that failed --> get thread
      new_mrl = curr_thread.mr_level - 1
      # self.current_mrl = new_mrl
      #get thread where mr_level is one less than current thread's mr_level
      new_thread = self.mr_threads.find_by(mr_level: new_mrl, name: curr_thread.name)
      #once get thread in lower mrl, find that subthread at lower mrl and set as new_subthread
      new_subth = new_thread.subthreads.find_by(name: current_subthread.name)
      new_subth.update(in_assessment: true)

      #swap in new subthread for old subthread
      return new_subth
    
    #if movement forward and passed
    elsif movement == 'forward' && current_subthread.status == 'passed'
      #if current subthread/thread at target_mrl, navigate to next subthread at normal MRL
      if curr_thread.mr_level == self.target_mrl 
        #get index of current thread in target mrl
        # binding.pry
        index_of_thread = threads_in_target_mrl.find_index(curr_thread)
        # curr_sub_name = current_subthread.name[0..2] #A.1

        #get all possible subthreads in current thread
        # subs_in_thread = curr_thread.subthreads.select {|sub| sub.questions.length > 0}
        ordered_subs_in_thread = curr_thread.subthreads.sort_by {|obj| obj.name.downcase}
        sub_index = ordered_subs_in_thread.find_index(current_subthread)

        #if subthread at end of thread, go to next thread (A.2 --> B.1)
        if sub_index == ordered_subs_in_thread.length - 1
          #get index of new thread
          new_thread = threads_in_target_mrl[index_of_thread + 1]
          #make sure no empty subthreads
          new_thread_subthreads = new_thread.subthreads.select { |sth| sth.questions.length > 0 }
          #get first subthread at index
          new_subth = new_thread_subthreads[0]

        else #if not last subthread in thread (A.1 --> A.2)
          #get next subthread at index + 1
          new_subth = ordered_subs_in_thread[sub_index + 1]
        end

        #return first question in new_subthread
        new_subth.update(in_assessment: true)
        return {new_subthread: new_subth, level_change: 'none'}

      #if current thread mrl does not equal target mrl and passed
      else 
        #get new_mrl which is current thread mrl + 1
        new_mrl = curr_thread.mr_level + 1
        # self.update(current_mrl: new_mrl)
        #get new thread that is at thread.mrl + 1 --> get new subthread
        new_thread = self.mr_threads.find_by(mr_level: new_mrl, name: curr_thread.name)
        #get new subthread
        new_subth = new_thread.subthreads.find_by(name: current_subthread.name)
        new_subth.update(in_assessment: true)
        return {new_subthread: new_subth, level_change: 'up'}
        
      end
    
    #if all answers null and status not set yet, navigate to next subthread in target mr_level
    elsif movement == 'forward' && current_subthread.status == nil
      #get index of current thread in target mrl
      th_in_target_mrl = threads_in_target_mrl.select {|th| th.name[0] == curr_thread.name[0]}[0]
      index_of_thread = threads_in_target_mrl.find_index(th_in_target_mrl)
      # binding.pry
      curr_sub_name = current_subthread.name[0..2] #A.1
      # subs_in_thread = th_in_target_mrl.subthreads.select {|sub| sub.questions.length > 0}
      #subthreads were out of order to needed to sort
      ordered_subs_in_thread = th_in_target_mrl.subthreads.sort_by {|obj| obj.name.downcase}
      sth = ordered_subs_in_thread.select { |st| st.name[0..2] == curr_sub_name}[0]
      
      sub_index = ordered_subs_in_thread.find_index(sth)
      # binding.pry
      #if subthread at end of thread, go to next thread (A.2 --> B.1)
      if sub_index == ordered_subs_in_thread.length - 1
        #get index of new thread
        new_thread = threads_in_target_mrl[index_of_thread + 1]
        #make sure no empty subthreads
        # new_thread_subthreads = new_thread.subthreads.select { |sth| sth.questions.length > 0 }
        new_thread_ordered_subs = new_thread.subthreads.sort_by {|obj| obj.name.downcase}
        #return first question in new_subthread
        new_subth = get_correct_subthread(new_thread_ordered_subs[0])
        
      else #if not last subthread in thread (A.1 --> A.2)
        #get next subthread at index + 1
        new_subth = get_correct_subthread(ordered_subs_in_thread[sub_index + 1])
        # binding.pry
      end
      return new_subth

    #if going backwards, switch back to target_mrl and go to previous subthread 
    elsif movement == 'backwards'
      #get current thread in target mrl
      th_in_target_mrl = threads_in_target_mrl.select {|th| th.name == curr_thread.name}[0]

      #get name of subbthread
      curr_sub_name = current_subthread.name[0..2] #A.1
      # subs_in_thread = th_in_target_mrl.subthreads.select {|sub| sub.questions.length > 0}
      ordered_subs_in_thread = th_in_target_mrl.subthreads.sort_by {|obj| obj.name.downcase}
      sth = ordered_subs_in_thread.select { |st| st.name[0..2] == curr_sub_name}[0]
      # sub_index = subs_in_thread.find_index(current_subthread)
      # binding.pry
      
      #if sth is not the first subthread in the current thread in target mrl
      if ordered_subs_in_thread[0] != sth 
        #get previous subthread in same thread
        sub_index = ordered_subs_in_thread.find_index(sth)
        prev_subthread = get_correct_subthread(ordered_subs_in_thread[sub_index - 1])
        # binding.pry
        #return last question in previous subthread
        return prev_subthread.questions.sort_by{|obj| obj.id}.last
      
      #if subthread is first in thread, get last subthread in previous thread
      else 
        #get index of current thread in target mrl
        index_of_thread = threads_in_target_mrl.find_index(th_in_target_mrl)
        #get previous thread
        prev_thread = threads_in_target_mrl[index_of_thread - 1]
        prev_thread_subs_ordered = prev_thread.subthreads.sort_by {|obj| obj.name.downcase}
        # prev_thread.subthreads.select { |sth| sth.questions.length > 0 }
        prev_subthread = get_correct_subthread(prev_thread_subs_ordered.last)
        #return last question in last subthread of previous thread
        # binding.pry
        return prev_subthread.questions.sort_by{|obj| obj.id}.last
      end

    end

  end

  #grab_length but for level switching
  def level_switch_length
    #find all subthreads where in assessment = true
    #get questions from each of those subthreads and add to array
    all_questions = []
    #count down from target_mrl
    (self.target_mrl).downto(1) do |mrl|
      if mrl == self.target_mrl
        all_questions = self.grab_length(self.target_mrl)

      #else, go through each thread and subthread and get subthreads that are in_assessment == true and get those questions
      else
        @current_level_ths = self.mr_threads.select {|th| th.mr_level == mrl}
        # subs_in_as = [] #subthreads in assessment
        @current_level_ths.each do |th|
          th.subthreads.each do |subth|
            if subth.in_assessment 
              subth.questions.each do |q|
                all_questions << q
              end
            end
          end
        end

      end
      
    end


    #return array
    return all_questions
  end

  #this returns an array that's all questions in assessment that match current mrl
  #make sure test assessments have current_mrl filled in
  def grab_length(mrl)
    # cmrl = self.current_mrl
    @th = self.mr_threads.select {|thread| thread.mr_level == mrl} 
    questions = []
    @th.each do |thread|
      # binding.pry
      ordered_subthreads = thread.subthreads.sort_by {|obj| obj.name.downcase}
      ordered_subthreads.each do |sth|
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
