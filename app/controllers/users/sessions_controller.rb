class Users::SessionsController < Devise::SessionsController
  respond_to :json
  def destroy
    super
  end
  private
  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { user: resource, token: current_token }, status: :ok
    elsif
      render json: { message: 'Error logging in.' }, status: :unauthorized
    end
  end
  def respond_to_on_destroy
    current_user ? log_out_success : log_out_failure
  end
  def log_out_success
    render json: { message: "Logged out." }, status: :ok
  end
  def log_out_failure
    render json: { message: "Logged out failure."}, status: :unauthorized
  end
  def current_token
    request.env['warden-jwt_auth.token']
  end
end
