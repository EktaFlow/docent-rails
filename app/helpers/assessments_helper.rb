module AssessmentsHelper
  require 'roo'
  def get_schema(created_assessment, id, p)
    # xlsx = Roo::Spreadsheet.open('./app/assets/xls/2020_deskbook.xlsm')

    if created_assessment.deskbook_version == "2018"
      xlsx = Roo::Spreadsheet.open('./app/assets/xls/Users_Guide_2018_Version1.xlsm')
      guide = xlsx.sheet("MRL Users Guide").parse()
      db = xlsx.sheet("Database")
      reftext = db.column(1)
    elsif created_assessment.deskbook_version == "2020"
      xlsx = Roo::Spreadsheet.open('./app/assets/xls/2020_deskbook.xlsm')
      guide = xlsx.sheet("Guide").parse()
      db = xlsx.sheet("Database")
      reftext = db.column(1)
    end

    letters = ['C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']

    last_thread = nil

    # guide.last_row
    (4..guide.length - 1).each do |i_count|
      #all rows past header rows, cycle through
      current_row = guide[i_count]
      if current_row[0] != nil
        next if p[:threads].exclude? current_row[0][0]
      end
      puts current_row
      # binding.pry
        #need to create 10 thread objects for each level of this thread
        (1..10).each do |count|
          #if thread is not already saved, do this cycle
          if current_row[0] != nil
            #create thread object
            thread = MrThread.create(name: current_row[0], mr_level: count, assessment_id: created_assessment.id)
            #saving for reference when thread name is nil, will just grab current thread
            last_thread = thread.name[0]
            #create subthread for this row
            subthread = Subthread.create(name: current_row[1], mr_thread_id: thread.id)

            #get string of reference text to search in the Database sheet
            str = '$' + letters[count - 1] + '$' + (i_count + 2).to_s
            #get index of that row
            index = reftext.find_index(str)
            if index
              #get that ref text row
              ref_row = db.row(index+1)
              #get the help text for that subthread
              subthread.help_text = ref_row[3]
              #set criteria text for the subthread

              subthread.criteria_text = ref_row[2]
            end
            subthread.save
          else
            #need to create 10 thread objects for each level of this thread
            #first column of this row is nil (still part of previous thread) so we just set the subthread to the last thread id
            #create subthread for this row
            # binding.pry
            @ths = MrThread.where(mr_level: count, assessment: created_assessment)
            @thread = @ths.select {|th| th.name[0] == last_thread}[0]
            next if @thread == nil
            subthread = Subthread.create(name: current_row[1], mr_thread_id: @thread.id)
            #set criteria text for the subthread
            # subthread.criteria_text = current_row[count + 1]
            #get string of reference text to search in the Database sheet
            str = '$' + letters[count - 1] + '$' + (i_count + 2).to_s
            #get index of that row
            index = reftext.find_index(str)
            if index
              #get that ref text row
              ref_row = db.row(index+1)
              #get the help text for that subthread
              subthread.help_text = ref_row[3]
              subthread.criteria_text = ref_row[2]
            end
            subthread.save
          end
        end
    end
    # return created_assessment
    @all_questions = set_questions(created_assessment)
    puts @all_questions
    return @all_questions
  end

  #looks like questions are starting in thread B and not A
  def set_questions(assessment)
    if assessment.deskbook_version == "2018"
      xlsx = Roo::Spreadsheet.open('./app/assets/xls/Users_Guide_2018_Version1.xlsm')
      q_aire = xlsx.sheet("Questionnaire").parse(headers: true)
    elsif assessment.deskbook_version == "2020"
      xlsx = Roo::Spreadsheet.open('./app/assets/xls/2020_deskbook.xlsm')
      q_aire = xlsx.sheet("Questionnaire").parse(headers: true)
    end

    assessment.mr_threads.each do |th|
      #get all threads
      #get all subthreads
      #making sure we're grabbing the right questions based on mrl
      th.subthreads.each do |sth|
        matching = q_aire.select {|item| item["Sub"] != nil && item["Sub"][0..2] == sth.name[0..2] && item["MRL"] == th.mr_level }
        matching.each do |q|
          @question = Question.create(question_text: q["Question"], subthread: sth)
        end
      end
    end
  end

  def add_team_members(team_members, assessment)
    team_members.each do |tm|
      user = User.find_by(email: tm[:email])
      if user
        newTM = TeamMember.create(assessment_id: assessment.id, user_id: user.id, role: tm[:role])
        assessment.team_members << newTM
      else
        nUser = User.invite!(email: tm[:email])
        newTm = TeamMember.create(assessment_id: assessment.id, user_id: nUser.id, role: tm[:role])
        assessment.team_members << newTm
      end
    end

  end

  def delete_all_attachments(assessment)
    assessment.file_attachments.each do |fa|
      fa.destroy
    end
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
