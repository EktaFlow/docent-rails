module AssessmentsHelper
  require 'pry'
  require 'roo'
  def get_schema(schema_file, threads, created_assessment)
    require 'json'
    # binding.pry
    # file = File.read("./app/assets/json/#{schema_file}.json")
    xlsx = Roo::Spreadsheet.open('./app/assets/xls/2020_deskbook.xlsm')
    xlsx.sheets
    # data_hash = JSON.parse(file)

    #sample threads array = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    # puts data_hash

    #threads array is which threads to include


    # threads.each do |th|
    #
    #   #grab current thread from data hash
    #   thread = data_hash[th - 1]
    #   # @thread = Thread.create({
    #   #   name: thread["threadName"],
    #   #   assessment: created_assessment,
    #   # })
    #   # assessment.threads << thread["threadName"]
    #   #run through subthreads of current thread
    #   thread["subThreads"].each do |subthread|
    #     #run through all mrls in  each subthread
    #     subthread["subThreadLevels"].each do |level|
    #       # @thread.update(mr_level: level["level"])
    #       # @thread.subthreads.create({
    #       #
    #       #   })
    #       #run through all questions in each mrl (in each subthread)
    #       level["questions"].each do |q|
    #         @question = Question.create(
    #           thread_id: thread["threadId"],
    #           thread_name: thread["threadName"],
    #           question_text: q["questionText"],
    #           question_id: q["questionId"],
    #           subthread_name: subthread["name"],
    #           subthread_id: subthread["subThreadId"],
    #           mr_level: level["level"],
    #           help_text: level["helpText"],
    #           criteria_text: level["criteriaText"],
    #           answered: false,
    #           assessment: assessment
    #         )
    #
    #       end
    #     end
    #   end
    # end
    # assessment.save
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
