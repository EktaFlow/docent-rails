class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :subthread

  def get_question_info
    #current question of assessment
    #number of questions
    #current question number
    #current thread
    #current subthread
    #list of threads
    #list of subthreads
    #answers array
    #files for question

    #current thread / all threads

  end
end
