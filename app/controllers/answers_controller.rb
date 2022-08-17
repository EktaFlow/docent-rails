class AnswersController < ApplicationController
  def index
    @question = Question.find(params[:question_id])
    if @question.answers.length
      render json: {answers: @question.answers}
    elsif @question.answers.length == 0
      render json: {answers: []}
    else
      render json: {errors: @question.errors.full_messages}
    end
  end

  def create
    #go through each of the answer params (params.map ? how to iterate through an object)
    #if all answer params match @question.answers.last
    #then don't save new answer
    @question = Question.find(params[:question_id])
    #do the above right here
    #check if question has any answers b4 this
    #if Answer.check_for_dupe(answer_params, @question.answers.last)
    @answer = Answer.create(answer_params)
    @question.answers << @answer
    @question.update(current_answer: @answer.answer)
    @question.update(answered: true)
    # if @answer.answer == 'no'
    #   @question.subthread.update(status: 'failed')
    # else
    #   @question.subthread.update(status: 'passed')
    # end
    if @question == @question.subthread.questions.last
      
      #use this status to update UI ?
      @failed = false
      @question.subthread.questions.each do |q|
        if q.answers.length > 0 && q.answers.last.answer.downcase == 'no'
          #should exit the for each loop once we have hit a failed question
          @failed = true
        # else
        #   @failed = false
        end
      end
      #pass true or false based on if there is a failed answer in one of the questions
      @question.subthread.update(status: @failed ? 'failed' : 'passed')
    end
    if @answer.save
      render json: {answer: @answer}
    else
      render json: {errors: @assessment.errors}, status: :unprocessable_entity
    end
  end

  # def revert_back
  #   @question = Question.find(params[:question_id])
  #   @old_answer = Answer.find(params[:answer_id])
  #   #old answer should fill in all fields but change who made the edit (reverted back) and the created at timing
  #   #add column to answer table called reverted bool
  #   # @new_answer = Answer.create(@old_answer)
  # end

  # def show
  #
  # end

  private

  def answer_params
    params.require(:answer).permit(
      # :id,
      :answer,
      :likelihood,
      :consequence,
      :risk_response,
      :greatest_impact,
      :mmp_summary,
      :objective_evidence,
      :assumptions_yes,
      :notes_yes,
      :what,
      :when,
      :who,
      :risk,
      :reason,
      :assumptions_no,
      :documentation_no,
      :assumptions_na,
      :assumptions_skipped,
      :notes_skipped,
      :notes_no,
      :notes_na
    )
  end
end
