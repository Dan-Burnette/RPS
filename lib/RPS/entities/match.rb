module RPS
  class Match < ActiveRecord::Base
    has_many :users
  end
end