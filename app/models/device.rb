class Device < ApplicationRecord
  has_secure_token :access_token

	before_create do
		n = 18 # Take this from project settings
    self.uid = rand((10**(n - 1))..(10**n)) # make something to add error if exist something....
  end

end
