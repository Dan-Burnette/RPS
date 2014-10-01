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
      
      user_matches = RPS::Match.where("user1 = ? OR user2 = ?", user.id, user.id)
      other_users = RPS::User.where("username != ?", username)
      #open_matches
      erb :main, :locals => {username: username, other_users: other_users, user_matches: user_matches } 
      
    else
      redirect to '/'
    end
    
  end

  post '/create_match' do
    user = RPS::User.find_by(username: params['user'])
    username = user.username
    other_users = RPS::User.where("username != ?", username)
    opponent = RPS::User.find_by(username: params['opponent'])
    match = RPS::Match.create(user1: user.id, user2: opponent.id)
    user_matches = RPS::Match.where("user1 = ? OR user2 = ?", user.id, user.id)
    erb :main, :locals => {username: username, other_users: other_users, user_matches: user_matches }
  end

  run! if __FILE__ == $0

end