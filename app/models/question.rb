class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :subthread

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
    @assessment = self.subthread.mr_thread.assessment
    @length_of_asm = ApplicationController.helpers.grab_length(@assessment)
    @position = @length_of_asm.find_index(self)
    q = {
      question_id: self.id,
      question_text: self.question_text,
      current_answer_text: self.current_answer,
      answered: self.answered == nil ? false : true,
      position: @position + 1,
      assessment_length: @length_of_asm.length,
      current_answer: self.answers.empty? ? [] : self.answers.last,
      structure: @assessment.list_of_threads,
      current_mrl: self.subthread.mr_thread.mr_level
    }
  end
end
