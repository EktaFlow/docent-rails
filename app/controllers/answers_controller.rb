class AnswersController < ApplicationController
  def index
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = Answer.new(answer_params)
    @answer.question = @question
    if @answer.save
      render json: {answer: @answer}
    else
      render json: {errors: @assessment.errors}, status: :unprocessable_entity
    end
  end

  def show
  end

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
