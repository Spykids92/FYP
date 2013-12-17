class User < ActiveRecord::Base
  has_many :generators
  has_many :results, :through=>:generators
  def self.create_with_omniauth(auth)
      create! do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        user.name = auth["info"]["name"]
      end
  end
  
end
