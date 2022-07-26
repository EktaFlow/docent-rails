class AssessmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    #get all assessments for current_user both shared and owned
    #do we need to separately grab the team members for each of these?
    @assessments = Assessment.where(owner_id: current_user.id)
    assessments_with_info = []

    #get team members & questions answered info
    @assessments.each do |am|
      assessments_with_info << am.get_info_for_dashboard('owned')
    end

    #get shared assessments & assessment inf
    tms = TeamMember.where(user_id: current_user.id)
    tms.each do |t|
      #if assessment of team member exists
      if Assessment.find_by(id: t.assessment_id)
        assessment = Assessment.find_by(id: t.assessment_id)
        assessments_with_info << assessment.get_info_for_dashboard('shared')
      end
    end

  #   tms.each do |t|
  #     assessment = Assessment.find_by(id: t.assessment.id)
  #     assessments_with_info << assessment.get_info_for_dashboard('shared')
  #   end

    render json: {assessments: assessments_with_info}
  end

  def show
    @assessment = Assessment.find(params[:assessment_id])
    if @assessment
      @question = @assessment.find_current_question
      render json: @question.all_info('none')
    else
      render json: {error: 'No assessment found'}
    end
  end

  def create
    @assessment = Assessment.new(assessment_params)
    # binding.pry
    @assessment.owner = current_user
    @assessment.current_mrl = params[:target_mrl]
    if params[:assessment][:level_switching] == nil
      @assessment.level_switching = false
    end
    if @assessment.save
      @schema = helpers.get_schema(@assessment, @assessment.id, params)
      if params[:team_members]
        # binding.pry
        helpers.add_team_members(params[:team_members], @assessment)
        # @assessment.add_team_members(params[:team_members])
      end
      render json: {assessment_id: @assessment.id}
    else
      render json: {errors: @assessment.errors}, status: :unprocessable_entity
    end
  end

  def update
    @assessment = Assessment.find(params[:id])
    # binding.pry
    # @assessment.update(name: params[:assess_name])
    @assessment.update(assessment_params)

    # binding.pry
    #trying to update all params that are not null (for edit assessment)
    # assessment_params.each do |key, value|
    #   if params["#{key}"] != nil && params["#{key}"] != ''
    #     @assessment.update("#{key}" => params["#{key}"])
    #   end
    # end
    # @assessment.update_attributes(params)
    render json: {assessment: @assessment}
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
    # @assessment.team_members.destroy_all
    @assessment = Assessment.find(params[:id])
    helpers.delete_all_attachments(@assessment)
    # @faa = FileAttach
    # tms = TeamMember.where(assessment_id: params[:id])
    # tms.destroy
    @assessment.destroy
    render json: {success: true}
  end

  def grab_criteria_data
    if params[:id] != "-1"
      @assessment = Assessment.find(params[:id])
    else
      @assessment = Assessment.where(owner: current_user)[0]
    end
    if @assessment
      render json: {threads: @assessment.report_grouping, info: @assessment, team_members: @assessment.team_members}
    else
      render json: {errors: @assessment.errors.full_messages}
    end
  end

  def get_all_tm
    @assessment = Assessment.find(params[:id])
    @tms_info = []
    @assessment.team_members.each do |tm|
      @user = User.find_by(id: tm.user_id)
      if @user
        @tm_info = {
          email: @user.email,
          role: tm.role
        }
        @tms_info << @tm_info
      end
    end

    render json: {team_members: @tms_info}
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
