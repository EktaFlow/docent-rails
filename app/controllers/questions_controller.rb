class QuestionsController < ApplicationController
  def index
  end

  #when navigating from a report
  def show
    @question = Question.find(params[:id])
    render json: {question: @question.get_info, subthread: @question.subthread, thread: @question.subthread.mr_thread, level_change: 'none'}
  end

  #next/previous from questions from questions page
  def pick_action
    @current_question = Question.find(params[:question_id])
    @assessment = Assessment.find(params[:assessment_id])
    #grab length gets all questions for the assessment (use for nonLS assessments)
    @questions = @assessment.grab_length
    #for non dropped subthreads
    @cq_index = @questions.find_index(@current_question)
    #for when question/subthread has been dropped
    subthread = @current_question.subthread
    position_in_subthread = subthread.questions.find_index(@current_question)
    #these two variables are how to move in the subthread (forward/backwards)
    @act = -1
    @pis = -1
    if params[:movement] == 'next'
      #non dropped subthreads
      @act = @cq_index + 1
      #dropped subthreads
      @pis = position_in_subthread + 1
    elsif params[:movement] == 'prev'
      #non dropped subthreads
      @act = @cq_index - 1
      #dropped subthreads
      @pis = position_in_subthread - 1
    end


    #end of assessment do not return question - 'next' button shouldnt be available anyway
    # if (@cq_index + 1) == (@questions.length - 1) || @cq_index == 0
    #   render json: {end_of_assessment: true, dropped_level: false}
    # end

    #base level setting to next question in array
    @next_question = @questions[@act]
    #for the response to see if a toast is needed
    @level_change = 'none'

    #no level switching - normal action (even switching between subthreads)
    #for this level, need to check if next subthread has been failed or not before navigating to question
    if @assessment.level_switching == false
      #next question in normal array
      @next_question = @questions[@act]

    #level switching on, but not at end/beginning of subthread
    elsif @assessment.level_switching == true && (position_in_subthread != subthread.questions.length - 1 && position_in_subthread != 0)
      #subthread could possibly be at another level
      @next_question = subthread.questions[@pis]

    #level switching on and at end of subthread
    elsif @assessment.level_switching == true && position_in_subthread == subthread.questions.length - 1
      #this set of items should only happen if action is next

      if params[:movement] == 'next'
      #if subthread has failed
        if subthread.status == 'failed'
          puts 'in failed'
          #update assessment to move down a level for this subthread
          @assessment.update(current_mrl: @assessment.current_mrl - 1)
          #grabbing the next question by dropping down a subthread
          @next_question = @assessment.switch_level(@current_question, 'forward')
          #updating message for toast on fe
          @level_change = 'down'
        #if subthread has passed
        elsif subthread.status == 'passed'
          puts 'in passed'
          #adjusting current_mrl back to target_mrl
          if @assessment.current_mrl != @assessment.target_mrl
            @assessment.update(current_mrl: @assessment.target_mrl)
            #grabbing the next subthread
            @next_question = @assessment.switch_level(@current_question, 'forward')
            #updating message for toast
            @level_change = 'up'
          else
            @next_question = @questions[@act]
          end
        else
          @next_question = @questions[@act]
        end
      else
        #if action was previous, not done with the subthread so just move back one position
        @next_question = subthread.questions[@pis]
      end

    #at the first question of subthread
    elsif @assessment.level_switching == true && position_in_subthread == 0
      #this set of items should only happen if action is prev
      if params[:movement] == 'prev'
        #switching back to target mrl, because level switching only applies to current subthread
        if @assessment.target_mrl != @assessment.current_mrl
          #we need to add this call if we do any other navigation, so we dont possibly mess up the level switching status and accidently grab the wrong question
          @assessment.update(current_mrl: @assessment.target_mrl)
          #grabbing the previous subthread
          @next_question = @assessment.switch_level(@current_question, 'backwards')
          #message for toast
          @level_change = 'up'
        else
          @next_question = @questions[@act]
        end
      else
        #at the start of the subthread moving forward, even w level switching on, no changes to subthread level should occur
        @next_question = subthread.questions[@pis]
      end
    end

    #rendering all information
    render json: @next_question.all_info(@level_change)
  end
end
