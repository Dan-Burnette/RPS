require_relative '../lib/rps.rb'
require_relative '../config/environments.rb'

require 'active_record'
require 'sinatra'
require 'sinatra/reloader'
require 'pry-byebug'

class RPS::Server < Sinatra::Application

  beats = {rock: "scissors", paper: "rock", scissors: "paper"}

  get '/' do 
    erb :login
  end

  get '/sign_up' do
    erb :sign_up
  end

  post '/signup_info' do
    username = params['username']
    #need to do pw digest stuff
    password_digest = params['password']
    new_user = RPS::User.create(username: username, password_digest: password_digest)
    redirect to '/'
  end

  post '/login_info' do
    #true for now, until I implement sessions, default should be false
    valid = false
    username = params['username']
    #need to do pw digest stuff
    password_digest = params['password']

    user = RPS::User.find_by(password_digest: password_digest)
    
    if (user != nil)
      valid = true
    end

    if (valid == true)
      other_users = RPS::User.where("password_digest != ?", password_digest)
      #open_matches
      erb :main, :locals => {other_users: other_users} 
      
    else
      redirect to '/'
    end

  end

  run! if __FILE__ == $0

end