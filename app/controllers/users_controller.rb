class UsersController < ApplicationController
  def reset_password_request
    existing = User.where(email: params[:email])
    if params[:email] != '' && existing.length > 0
      UserMailer.reset_password(existing[0]).deliver_now
      render json: {message: 'success'}
    end
  end

  def reset_pwd
    user = User.find_by(reset_password_token: params[:reset_password_token])
    if user && params[:password] == params[:password_confirmation]
      user.update(password: params[:password])
      if user.save!
        render json: {message: 'success'}
      else
        render json: {message: user.errors.full_messages}
      end
    end
  end
end
