require 'rubygems' if RUBY_VERSION < "1.9"
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'gon-sinatra'

Sinatra::register Gon::Sinatra

############
## METHODS #
############

def prep_dictionary(filename='enable.txt')
  # Assumes filename is space-delimited text file. Returns filename's contents as arr.
  f = open(filename)
  return f.read.split(" ")
end

def select_word(dictionary, difficulty)
  # Assumes dictionary is arr, difficulty is int. Returns random item from dictionary of length equal to difficulty.
  index = rand(dictionary.length)
  if dictionary[index].length == difficulty
    return dictionary[index]
  else
    return select_word(dictionary, difficulty)
  end
end

def select_crimes(dictionary, difficulty)
  # Assumes dictionary is arr, difficulty is int. Returns arr of n unique random items from dictionary, where n equals difficulty.
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
  # Assumes dictionary1 and dictionary2 are arr. Returns a str that concatenates a random item from dictionary1 with a random item from dictionary2.
  index = rand(dictionary1.length)
  nickname = dictionary1[index]
  index = rand(dictionary2.length)
  return nickname += " " + dictionary2[index]
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
  # Assumes guess and word are str. Returns an arr of indices at which word equals guess, or nil if no match exists.
  indices = []
  word = word.split('')
  word.each_with_index do |x, idx|
    indices << idx if x == guess
  end
  indices.empty? ? nil : indices
end

def reveal_letters(current_str, guess, indices)
  # Assumes current_str is str, guess is str, and indices is arr. Returns current_str with guess subsituted for each index in indices. Toggles win state if zero unknown chars remain in current_str.
  current_str = current_str.split('')
  indices.each {|x| current_str[x] = guess}
  @@win = true if !current_str.include?('_')
  return current_str.join
end

###########
## ROUTES #
###########

get '/' do
  erb :landing
end

post '/' do
  redirect '/setup'
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
  @@difficulty = 4 if @@difficulty < 4
  prep_game()
  redirect '/game'
end

get '/game' do
  gon.missed_appeals = @@missed_appeals
  erb :game, :layout => false, :locals => {:word => @@word, :current_str => @@current_str, :wrong_letters => @@wrong_letters, :missed_appeals => @@missed_appeals, :cheat => @@cheat, :name => @@name, :nickname => @@nickname, :crimes => @@crimes}
  if params['guess'] != '' && params['guess'] != nil
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
  erb :game, :layout => false, :locals => {:word => @@word, :current_str => @@current_str, :wrong_letters => @@wrong_letters, :missed_appeals => @@missed_appeals, :cheat => @@cheat, :name => @@name, :nickname => @@nickname, :crimes => @@crimes}
end

post '/game' do
  redirect '/executed'
end

get '/pardoned' do
  erb :pardoned, :locals => {:name => @@name, :nickname => @@nickname, :word => @@word, :guess_counter => @@guess_counter, :missed_appeals => @@missed_appeals}
end

post '/pardoned' do
  redirect '/setup'
end

get '/executed' do
  erb :executed, :locals => {:name => @@name, :nickname => @@nickname, :word => @@word}
end

post '/executed' do
  redirect '/setup'
end
