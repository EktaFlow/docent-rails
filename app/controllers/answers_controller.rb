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
    @question = Question.find(params[:question_id])
    @answer = Answer.new(answer_params)
    @question.answers << @answer
    @question.update(current_answer: @answer.answer)
    @question.update(answered: true)
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
      :id,
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
