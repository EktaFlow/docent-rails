class QuestionsController < ApplicationController
  def index
  end

  #next from questions (either previous)
  def action
    @current_question = Question.find(params[:question_id])
    @assessment = Assessment.find(params[:assessment_id])
    @questions = @assessment.grab_length
    #for non dropped subthreads
    @cq_index = @questions.find_index(@current_question)
    subthread = @current_question.subthread
    #for when question/subthread has been dropped
    position_in_subthread = subthread.questions.find_index(@current_question)
    @act = nil
    @pis = nil
    if params[:action] == 'next'
      @act = @cq_index + 1
      @pis = position_in_subthread + 1
    elsif params[:action] == 'prev'
      @act = @cq_index - 1
      @pis = position_in_subthread - 1
    end


    #end of assessment
    if @cq_index + 1 == @questions.length -1 || @cq_index == 0
      render json: {end_of_assessment: true, dropped_level: false}
    end

    @next_question = nil
    @level_change = 'none'

    #no level switching - normal action (even switching between subthreads)
    if @assessment.level_switching == false
      @next_question = @questions[@act]

    #level switching on, but not at end of subthread
    elsif @assessment.level_switching == true && (if position_in_subthread != subthread.questions.length - 1 || position_in_subthread != 0)
      @next_question = subthread.questions[@pis]

    #level switching on and at end of subthread
    elsif @assessment.level_switching == true && position_in_subthread == subthread.questions.length - 1
      #if subthread has failed
      if params[:failed_subthread] == true
        @assessment.update(current_mrl: @assessment.target_mrl - params[:dropped])
        @next_question = @assessment.switch_level(@current_question)
        @level_change = 'down'
      #if subthread has passed
      else
        @assessment.update(current_mrl: @assessment.target_mrl)
        @next_question = @assessment.next_subthread_after_ls(@current_question, params[:action])
        @level_change = 'up'
      end
    elsif @assessment.level_switching == true && position_in_subthread == 0
      @assessment.update(current_mrl: @assessment.target_mrl)
      @next_question = @assessment.next_subthread_after_ls(@current_question, params[:action])
      @level_change = 'up'
    end

    render json: {question: @next_quesiton.get_info, subthread: @next_question.subthread, thread: @next_question.subthread.mr_thread, level_change: @level_change}
  end

end
