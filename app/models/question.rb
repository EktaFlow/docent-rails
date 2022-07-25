class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :subthread
  has_many :file_attachment_answers
  has_many :file_attachments, through: :file_attachment_answers

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
    @length_of_asm = @assessment.grab_length
    @position = @length_of_asm.find_index(self)
    q = {
      question_id: self.id,
      question_text: self.question_text,
      current_answer_text: self.current_answer,
      answered: self.answered == nil ? false : true,
      position: @position + 1,
      assessment_length: @length_of_asm.length,
      current_answer: self.answers.empty? ? [] : self.answers.last,
      all_answers: self.answers.empty? ? [] : self.answers.select{|a| a.answer != nil},
      # new_answer: Answer.create, 
      structure: @assessment.list_of_threads,
      current_mrl: self.subthread.mr_thread.mr_level,
      files: []
    }
    if self.file_attachments.length
      self.file_attachments.each do |fa|
        ff = {
          url: fa.outside_file.attachment ? fa.outside_file.attachment.blob.url : nil,
          name: fa.file_name,
        }
        q[:files] << ff
      end
    end
    return q
  end

  def grab_location
    st = self.subthread
    index = st.questions.find_index(self) + 1
    str = st.name[0..2] + ' Q#' + index.to_s
    return str
  end

  def all_info(lc)
    # binding.pry
    @assessment = self.subthread.mr_thread.assessment
    return {question: self.get_info, subthread: self.subthread, thread: self.subthread.mr_thread, assessment_id: @assessment.id, assessment_info: {targetDate: @assessment.target, additionalInfo: @assessment.scope}, level_change: lc }
  end
end
