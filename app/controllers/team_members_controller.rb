class TeamMembersController < ApplicationController
  def show
  end

  def create
    @assessment = Assessment.find(params[:assessment_id])
    @user = User.find_by(email: params[:user][:email])
    if @user
      @tm = TeamMember.create(user: @user, assessment: @assessment)
      return json: {team_member: @tm, newUser: false}
    else
      @u = User.invite!(email: params[:user][:email], name: params[:user][:name])
      @tm = TeamMember.create(user: @u, assessment: @assessment)
      return json: {team_member: @tm, newUser: true}
    end
  end
end
