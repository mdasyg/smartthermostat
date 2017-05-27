class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  has_many :devices, inverse_of: :user
  has_many :schedules, inverse_of: :user

  #	def id
#		return 4
#	end

end
