class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :subthread
  belongs_to :mr_thread, :through => :subthread
  belongs_to :assessment, :through => :mr_thread

  def get_info
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

    @length_of_asm = helpers.grab_length(self.assessment)
    @position = @length_of_asm.find_index(self)
    q = {
      question_text: self.question_text,
      current_answer: self.current_answer,
      answered: self.answered,
      position: @position,
      assessment_length: @length_of_asm,
      answers: self.answers,
      structure: self.assessment.list_of_threads
    }
  end
end
