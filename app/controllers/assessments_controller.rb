class AssessmentsController < ApplicationController
  def index
    #get all assessments for current_user both shared and owned
    #do we need to separately grab the team members for each of these?
    @assessments = Assessment.where(owner_id: current_user.id)
    assessments_with_info = []

    #get team members & questions answered info
    @assessments.each do |am|
      assessments_with_info << am.get_info_for_dashboard('owned')
    end

    #get shared assessments & assessment info
    tms = TeamMember.where(user_id: current_user.id)
    tms.each do |t|
      assessment = Assessment.find_by(assessment_id: t.assessment.id)
      assessments_with_info << assessment.get_info_for_dashboard('shared')
    end

    render json: {assessments: assessments_with_info}
  end

  def show
    @assessment = Assessment.find(params[:assessment_id])
    if @assessment
      @question = @assessment.find_current_3question
      render json: {question: @question.get_info, subthread: @question.subthread, thread: @question.subthread.mr_thread, assessment_id: @assessment.id}
    else
      render json: {error: 'No assessment found'}
    end
  end

  def create
    @assessment = Assessment.new(assessment_params)
    @assessment.owner = current_user
    @assessment.current_mrl = params[:target_mrl]
    if @assessment.save
      @schema = helpers.get_schema(@assessment)
      if params[:team_members]
        helpers.add_team_members(params[:team_members], @assessment)
      end
      render json: {assessment: @assessment.get_info_for_dashboard}
    else
      render json: {errors: @assessment.errors}, status: :unprocessable_entity
    end
  end

  def grab_base_report
    @assessment = Assessment.find(params[:id])
    if @assessment
      render json: {threads: @assessment.report_grouping, info: @assessment, team_members: @assessment.team_members}
    else
      render json: {errors: @assessment.errors.full_messages}
    end
  end

  #get_files 
  def file_explorer
    @assessment = Assessment.find(params[:id])
    if @assessment
      render json: {files: @assessment.get_files_for_explorer}
    else
      render json: {errors: @assessment.errors.full_messages}
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
