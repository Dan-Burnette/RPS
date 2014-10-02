require_relative '../lib/rps.rb'
require_relative '../config/environments.rb'

require 'active_record'
require 'json'
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
    valid = false
    username = params['username']
    #need to do pw digest stuff
    password_digest = params['password']
    user = RPS::User.find_by(password_digest: password_digest)

    if (user != nil)
      valid = true
    end

    if (valid == true)
      query = params.map{|k,v| "#{k}=#{v}"}.join("&") 
      puts query
      redirect to("/main?#{query}")
    else
      redirect to '/'
    end
# 
  end

  get '/main' do
    username = params['username']
    #need to do pw digest stuff
    password_digest = params['password']
    user = RPS::User.find_by(password_digest: password_digest)

    if (user != nil)
      valid = true
    end

  if (valid == true)
      user_matches = RPS::Match.where("user1 = ? OR user2 = ?", user.id, user.id)
      my_id = (RPS::User.find_by(username: username)).id
      my_moves = []
      enemy_moves = []
      user_matches.map do |m|
        my_move = []
        enemy_move = []
        if (m.user1 == my_id)
          my_move = m.move1
          enemy_move = m.move2
        elsif (m.user2 == my_id)
          my_move = m.move2
          enemy_move = m.move1
        end
        my_moves.push(my_move)
        enemy_moves.push(enemy_move)
      end

      other_users = RPS::User.where("username != ?", username)
      puts my_moves
      puts enemy_moves
      erb :main, :locals => {username: username, other_users: other_users, user_matches: user_matches }
    else
      redirect to '/'
    end
  
  end


  post '/create_match' do
    #Send the match back to the AJAX success function and append it
    user = RPS::User.find_by(username: params['user'])
    username = user.username
    opponent = RPS::User.find_by(username: params['opponent'])
    match = RPS::Match.create(user1: user.id, user2: opponent.id)
    json = {id: match.id.to_s, user1: username, user2: opponent.username}.to_json
  end

  post '/save_move' do
    username = params['username']
    move = params['move']
    match_id = params['matchid']

    #Find the match to update the move
    match = RPS::Match.find_by(id: match_id)\

    #Find the id of the user
    user_id = (RPS::User.find_by(username: username)).id
    #Find out which user is the one making the move and save it
    if (match.user1 == user_id)
      match.move1 = move
      match.save
    elsif (match.user2 == user_id)
      match.move2 = move
      match.save
    end
  end

  run! if __FILE__ == $0

end