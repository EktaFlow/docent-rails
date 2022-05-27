class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    # binding.pry
    build_resource(sign_up_params)
    resource.save
    resource.skip_confirmation!
    sign_up(resource_name, resource) if resource.persisted?
    resource.persisted? ? register_success : register_failed
  end

  # def sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up) do |user_params|
  #     user_params.permit(:name, :company_name, :email, :password, :password_confirmation)
  #   end
  # end
  private
  # def respond_with(resource, _opts = {})
  #   binding.pry
  #   resource.persisted? ? register_success : register_failed
  # end
  def register_success
    render json: { message: 'Signed up.' }
  end
  def register_failed
    render json: { message: "Signed up failure." }
  end

  def sign_up_params
    params[:user].permit(:name, :email, :company_name, :password, :password_confirmation)
  end

end
