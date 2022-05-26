class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  # protect_from_forgery with: :null_session
  respond_to :json
  skip_before_action :verify_authenticity_token, if: :devise_controller?
  protect_from_forgery unless: -> { request.format.json? }


end
