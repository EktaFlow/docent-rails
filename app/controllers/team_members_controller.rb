class TeamMembersController < ApplicationController
  def show
  end

  def create
    @assessment = Assessment.find(params[:user][:assessment_id])
    @user = User.find_by(email: params[:user][:email])
    if @user
      @tm = TeamMember.create(user_id: @user.id, assessment: @assessment, role: params[:user][:role])
      @assessment.team_members << @tm
      # UserMailer.shared_assessment(@user, current_user, @assessment).deliver
      render json: {team_member: @user.email, assessment: @assessment.get_info_for_dashboard('owned'), newUser: false}
    else
      @u = User.invite!(email: params[:user][:email])
      @tm = TeamMember.create(user_id: @u.id, assessment: @assessment, role: params[:user][:role])
      # @assessment.team_members << @tm
       # UserMailer.shared_assessment(@u, current_user, @assessment).deliver
      render json: {team_member: @u.email, assessment: @assessment.get_info_for_dashboard('owned'), newUser: true}
    end
  end
end
