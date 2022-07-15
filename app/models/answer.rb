class Answer < ApplicationRecord
  belongs_to :question

  def self.check_for_dupe(answer_params, last_a)
    #figure out way to loop so you dont have to write out 1 by 1
    #iterate through object
    #might have to grab the keys for all of them and match that some how
    if answer_params[:answer] == last_a.answer
    end
    if answer_params[:likelihood] == last_a.likelihood
    end
  end

end
