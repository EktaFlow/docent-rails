class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  #user_signed_in?
  #current_user
  #user_session
end
