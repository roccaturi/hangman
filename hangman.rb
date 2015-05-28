require 'rubygems' if RUBY_VERSION < "1.9"
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'gon-sinatra'

Sinatra::register Gon::Sinatra

def prep_dictionary(filename='enable.txt')
  # Assumes filename is space-delimited text file.  Returns filename's contents as arr.
  f = open(filename)
  return f.read.split(" ")
end

def select_word(dictionary, difficulty)
  # Assumes dictionary is arr, difficulty is int.  Returns random item from dictionary of length equal to difficulty.
  index = rand(dictionary.length)
  if dictionary[index].length == difficulty
    return dictionary[index]
  else
    return select_word(dictionary, difficulty)
  end
end

def select_crimes(dictionary, difficulty)
  # Assumes dictionary is arr, difficulty is int.  Returns arr of n unique random items from dictionary, where n equals difficulty.
  crimes = []
  difficulty.times do
    found = false
    while !found
      index = rand(dictionary.length)
      unless crimes.include?(dictionary[index])
        crimes << dictionary[index]
        found = true
      end
    end
  end
  return crimes.each {|crime| crime.gsub!(/[_]/, " ")}
end

def select_nickname(dictionary1, dictionary2)
  # Assumes dictionary1 and dictionary2 are arr.  Returns a str that concatonates a random item from dictionary1 with a random item from dictionary2.
  index = rand(dictionary1.length)
  nickname = dictionary1[index]
  index = rand(dictionary2.length)
  nickname += " " + dictionary2[index]
  return nickname
end

def prep_game()
  # (Re)Assigns class variables at the start of first or subsequent games.
  word_pool = prep_dictionary()
  @@word = select_word(word_pool, @@difficulty).upcase
  crime_pool = prep_dictionary('charges.txt')
  adjective_pool = prep_dictionary('adjectives.txt')
  noun_pool = prep_dictionary('nouns.txt')
  @@nickname = select_nickname(adjective_pool, noun_pool)
  @@crimes = select_crimes(crime_pool, @@difficulty)
  @@missed_appeals = 0
  @@guess_counter = 0
  @@current_str = '_' * @@word.length
  @@wrong_letters = []
  @@win = false
  @@cheat = false
end

def check_guess(guess, word)
  # Assumes guess and word are str.  Returns an arr of indices at which word equals guess, or nil if no matches exist.
  indices = []
  word = word.split('')
  word.each_with_index do |x, idx|
    if x == guess
      indices << idx
    end
  end
  indices.empty? ? nil : indices
end

def reveal_letters(current_str, guess, indices)
  # Assumes current_str is str, guess is str, and indices is arr.  Returns current_str with guess subsituted for each index in indices.  Toggles win state if no unknown characters in current_str remain.
  current_str = current_str.split('')
  indices.each {|x| current_str[x] = guess}
  @@win = true if !current_str.include?('_')
  return current_str.join
end

get '/' do
  erb :landing
end

post '/' do
  if params["value"] == "What's going on here?"
    rediret '/about'
  else
    redirect '/setup'
  end
end

get '/about' do
  erb :about
end

get '/about*' do
  redirect '/about'
end

post '/about' do
  redirect '/setup'
end

get '/setup' do
  erb :setup
end

post '/setup' do
  @@name = params['name']
  @@difficulty = params['difficulty'].to_i
  @@difficulty = 20 if @@difficulty > 20
  @@difficulty = 3 if @@difficulty < 3
  prep_game()
  redirect '/game'
end

get '/game' do
  gon.missed_appeals = @@missed_appeals
  erb :game, :layout => false, :locals => {:difficulty => @@difficulty, :word => @@word, :current_str => @@current_str, :wrong_letters => @@wrong_letters, :missed_appeals => @@missed_appeals, :cheat => @@cheat, :crimes => @@crimes, :nickname => @@nickname, :name => @@name}
  if params["guess"] != nil
    guess = params['guess'].capitalize
    @@cheat = true if params['cheat'] == 'true'
    guess_locations = check_guess(guess, @@word)
    @@guess_counter += 1
    if guess_locations.nil?
      @@wrong_letters << guess
      @@missed_appeals += 1
    else
      @@current_str = reveal_letters(@@current_str, guess, guess_locations)
    end
    if @@win
      redirect '/pardoned'
    end
  end
  gon.missed_appeals = @@missed_appeals
  erb :game, :layout => false, :locals => {:difficulty => @@difficulty, :word => @@word, :current_str => @@current_str, :wrong_letters => @@wrong_letters, :missed_appeals => @@missed_appeals, :cheat => @@cheat, :crimes => @@crimes, :nickname => @@nickname, :name => @@name}
end

post '/game' do
  redirect '/executed'
end

get '/pardoned' do
  erb :pardoned, :locals => {:guess_counter => @@guess_counter, :missed_appeals => @@missed_appeals, :name => @@name, :nickname => @@nickname, :word => @@word}
end

post '/pardoned' do
  redirect '/setup'
end

get '/executed' do
  erb :executed, :locals => {:current_str => @@current_str, :word => @@word, :difficulty => @@difficulty, :name => @@name, :nickname => @@nickname}
end

get '/executed*' do
  redirect '/about'
end

post '/executed' do
  redirect '/setup'
end
