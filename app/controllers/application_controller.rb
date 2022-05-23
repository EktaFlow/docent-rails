class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  skip_before_action :verify_authenticity_token
  # before_action :authenticate_user!
  #user_signed_in?
  #current_user
  #user_session
  def current_user
    User.first
  end
end
