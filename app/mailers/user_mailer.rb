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
    mail(:to => user.email, :subject => "Someone has shared an assessment with you on Docent")
  end
end
