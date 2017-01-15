class Device < ApplicationRecord
  has_secure_token :access_token
end
