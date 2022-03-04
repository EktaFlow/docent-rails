class AssessmentsController < ApplicationController
  def index
    #get all assessments for current_user both shared and owned
    #do we need to separately grab the team members for each of these?
    @assessments = Assessment.where(owner_id: current_user.id)
    assessments_with_info = []

    #get team members & questions answered info
    @assessments.each do |am|
      assessments_with_info << am.get_info_for_dashboard
    end

    #get shared assessments & assessment info
    # tms = TeamMember.where(user_id: current_user.id)
    # tms.each do |t|
    #   assessment = Assessment.find_by(assessment_id: t.assessment.id)
    #   assessments_with_info << assessment.get_info_for_dashboard
    # end

    render json: {assessments: assessments_with_info}
  end

  def show
    @assessment = Assessment.find(params[:assessment_id])
    if @assessment
      #what do we need for assessments to work?
      #assessment information
      #first question of assessment
      #number of questions
      #current question number
      #current thread
      #current subthread
      #list of threads
      #list of subthreads
      #answers array
      #files for question
    else
      render json: {error: 'No assessment found'}
    end
  end

  def create
    @assessment = Assessment.new(assessment_params)
    @assessment.current_mrl = params[:target_mrl]
    if @assessment.save?
      @schema = get_schema(@assessment)
      add_team_members(params[:team_members], @assessment)
      render json: {assessment: @assessment.get_info_for_dashboard}
    else
      render json: {errors: @assessment.errors}, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def assessment_params
    params.require(:assessment).permit(
      :id,
      :target_mrl,
      :current_mrl,
      :level_switching,
      :target,
      :location,
      :deskbook_version,
      :threads,
      :name,
      :scope
    )

  end
end
