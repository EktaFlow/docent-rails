class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, :confirmable, jwt_revocation_strategy: JwtDenylist

  has_many :assessments
  has_many :answers

  has_many :team_members

  # def generate_jwt
  #   JWT.encode({ id: id,
  #     exp: 60.days.from_now.to_i },
  #    Rails.application.secrets.secret_key_base)
  #  end
end
