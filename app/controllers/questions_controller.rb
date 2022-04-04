class QuestionsController < ApplicationController
  def index
  end

  def show
    @question = Question.find(params[:question_id])
    render json: {question: @question.get_info, subthread: @question.subthread, thread: @question.subthread.mr_thread}
  end

  def create
  end
end
