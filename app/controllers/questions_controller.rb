class QuestionsController < ApplicationController
  def index
  end

  #next from questions (either previous)
  def next
    @current_question = Question.find(params[:question_id])
    @questions = Assessment.find(params[:assessment_id]).grab_length
    @cq_index = @questions.find_index(@current_question)
    if @cq_index + 1 == @questions.length -1
      render json: {end_of_assessment: true}
    else
      @question = @questions[@cq_index + 1]
      render json: {question: @question.get_info, subthread: @question.subthread, thread: @question.subthread.mr_thread}
    end
  end

  def prev
    @current_question = Question.find(params[:question_id])
    @questions = Assessment.find(params[:assessment_id]).grab_length
    @cq_index = @questions.find_index(@current_question)
    if @cq_index + 1 == @questions.length -1
      render json: {end_of_assessment: true}
    else
      @question = @questions[@cq_index + 1]
      render json: {question: @question.get_info, subthread: @question.subthread, thread: @question.subthread.mr_thread}
    end
  end
end
