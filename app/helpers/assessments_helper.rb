module AssessmentsHelper
  require 'pry'
  def get_schema(schema_file, threads, assessment)
    require 'json'
    file = File.read("./app/assets/json/#{schema_file}.json")
    data_hash = JSON.parse(file)

    #sample threads array = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    # puts data_hash

    #threads array is which threads to include
    threads.each do |th|

      #grab current thread from data hash
      thread = data_hash[th - 1]

      #run through subthreads of current thread
      thread["subThreads"].each do |subthread|

        #run through all mrls in  each subthread
        subthread["subThreadLevels"].each do |level|

          #run through all questions in each mrl (in each subthread)
          level["questions"].each do |q|
            @question = Question.create(
              thread_id: thread["threadId"],
              thread_name: thread["threadName"],
              question_text: q["questionText"],
              question_id: q["questionId"],
              subthread_name: subthread["name"],
              subthread_id: subthread["subThreadId"],
              mr_level: level["level"],
              help_text: level["helpText"],
              criteria_text: level["criteriaText"],
              answered: false,
              assessment: assessment
            )
            
          end
        end
      end

      # thread_data = {
      #   "thread_id": thread_object.id,
      #   "thread_name": thread_object.name
      # }

    end
  end
end
