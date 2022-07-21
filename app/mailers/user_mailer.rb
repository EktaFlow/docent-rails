class UserMailer < ActionMailer::Base
  default :from => "info@mfgdocent.com"

  # def welcome_email(user)
  #   @user = user
  #   @url  = "http://example.com/login"
  #   mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  # end

  def shared_assessment(user, inviter, assessment)
    @user = user
    @inviter = inviter
    @assessment = assessment
    @url = "https://web.mfgdocent.com"
    mail(:to => @user.email, :subject => "Someone has shared an assessment with you on Docent")
  end

  def reset_password(user)
    create_reset_password_token(user)
    @user = user
    @url = "https://web.mfgdocent.com/password-reset?reset_password_token=#{@user.reset_password_token}"
    mail(:to => @user.email, :subject => 'Reset Your Docent Password')
  end

  private

  def create_reset_password_token(user)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    @token = raw
    user.reset_password_token = hashed
    user.reset_password_sent_at = Time.now.utc
    user.save
  end
end
