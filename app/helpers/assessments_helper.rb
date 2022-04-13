module AssessmentsHelper
  require 'roo'
  def get_schema(created_assessment)
    xlsx = Roo::Spreadsheet.open('./app/assets/xls/2020_deskbook.xlsm')

    guide = xlsx.sheet("Guide").parse()
    db = xlsx.sheet("Database")
    reftext = db.column(1)
    letters = ['C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']

    last_thread = nil

    # guide.last_row
    (5..guide.length - 1).each do |i|
      #all rows past header rows, cycle through
      current_row = guide[i]
      puts current_row
        #need to create 10 thread objects for each level of this thread
        (1..10).each do |count|
          #if thread is not already saved, do this cycle
          if current_row[0] != nil
            #create thread object
            thread = MrThread.create(name: current_row[0], mr_level: count, assessment_id: created_assessment.id)
            #saving for reference when thread name is nil, will just grab current thread
            last_thread = thread.id
            #create subthread for this row
            subthread = Subthread.create(name: current_row[1], mr_thread_id: thread.id)
            #set criteria text for the subthread
            #check if text in box and not text in popover is sufficient for critieria text
            subthread.criteria_text = current_row[count + 1]
            #get string of reference text to search in the Database sheet
            str = '$' + letters[count - 1] + '$' + i.to_s
            #get index of that row
            index = reftext.find_index(str)
            if index
              #get that ref text row
              ref_row = db.row(index+1)
              #get the help text for that subthread
              subthread.help_text = ref_row[3]
            end
            subthread.save
          else
            #need to create 10 thread objects for each level of this thread
            #first column of this row is nil (still part of previous thread) so we just set the subthread to the last thread id
            #create subthread for this row
            subthread = Subthread.create(name: current_row[1], mr_thread_id: last_thread)
            #set criteria text for the subthread
            subthread.criteria_text = current_row[count + 1]
            #get string of reference text to search in the Database sheet
            str = '$' + letters[count - 1] + '$' + i.to_s
            #get index of that row
            index = reftext.find_index(str)
            if index
              #get that ref text row
              ref_row = db.row(index+1)
              #get the help text for that subthread
              subthread.help_text = ref_row[3]
            end
            subthread.save
          end
        end
    end

    @all_questions = set_questions(created_assessment)
    return @all_questions
  end

  def set_questions(assessment)
    xlsx = Roo::Spreadsheet.open('./app/assets/xls/2020_deskbook.xlsm')
    q_aire = xlsx.sheet("Questionnaire").parse(headers: true)

    assessment.mr_threads.each do |th|
      #get all threads
      #get all subthreads
      #making sure we're grabbing the right questions based on mrl
      th.subthreads.each do |sth|
        matching = q_aire.select {|item| item["Sub"] == sth.name && item["MRL"] == th.mr_level}
        matching.each do |q|
          @question = Question.create(question_text: q["Question"], subthread: sth)
        end
      end
    end
  end

  def add_team_members(team_members, assessment)
    team_members.each do |tm|
      user = User.find_by(email: tm.email)
      if user
        ntm = TeamMember.create(assessment_id: assessment.id, user_id: user.id, role: tm.role)
        assessment.team_members << ntm
      else
        nUser = User.invite!(email: tm.email)
        ntm = TeamMember.create(assessment_id: assessment.id, user_id: nUser.id, role: tm.role)
        assessment.team_members << ntm
      end
    end

  end

  def grab_length(assessment)
    cmrl = assessment.current_mrl
    @th = assessment.mr_threads.select {|thread| thread.mr_level == cmrl}
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


# assessment.threads[0].subthreads[0].question[0]
# @threads = Threads.where(assessment_id: id);
# @threads.select {mrl: 4}
# assessment.threads =
#
# question.subthread.thread.assessment
# question.assessment
# [{
# name: 'name',
# subthreads: [
#   {name: 'name',
#   questions: [
#     {}, {}
#   ]},
#   {}
#
# ]
# }]
