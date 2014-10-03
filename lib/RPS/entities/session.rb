module RPS
  class Session < ActiveRecord::Base
    belongs_to :user

    def generate_id
      self.session_id = Digest::SHA1.hexdigest(Time.now.to_i.to_s)
    end
    
  end
end