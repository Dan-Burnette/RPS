module RPS
  class User < ActiveRecord::Base
    has_many :matches
    has_many :sessions
  end
end