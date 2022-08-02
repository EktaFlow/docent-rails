class Subthread < ApplicationRecord
  belongs_to :mr_thread
  has_many :questions, dependent: :destroy

  def get_sub_info 
    subth = {
      id: self.id, 
      name: self.name, 
      mr_thread_id: self.mr_thread_id, 
      status: self.status, 
      criteria_text: self.criteria_text, 
      help_text: self.help_text, 
      questions: self.questions.sort_by{|obj| obj.id}, 
      mr_level: self.mr_thread.mr_level
    }
  end
end
