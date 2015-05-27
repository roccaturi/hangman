require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'sinatra/reloader'

def prep_dictionary(filename='enable.txt')
  f = open(filename)
  return f.read.split(" ")
end

def select_word(dictionary, difficulty)
  index = rand(dictionary.length)
  if dictionary[index].length == difficulty
    return dictionary[index]
  else
    return select_word(dictionary, difficulty)
  end
end

def check_guess(guess, word)
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
  current_str = current_str.split('')
  indices.each {|x| current_str[x] = guess}
  @@win = true if !current_str.include?("_")
  return current_str.join
end

def setup
  word_pool = prep_dictionary()
  @@difficulty = 4
  @@word = select_word(word_pool, @@difficulty)
  @@appeals = 0
  @@current_str = "_" * @@word.length
  @@wrong_guesses = []
  @@win = false
end

get '/' do
  erb :landing
end

get '/setup' do
  erb :setup
end

setup()

get '/game' do
  erb :game, :locals => {:difficulty => @@difficulty, :word => @@word, :current_str => @@current_str, :wrong_guesses => @@wrong_guesses, :appeals => @@appeals}
  if params["guess"] != nil
    guess = params["guess"]
    guess_locations = check_guess(guess, @@word)
    if guess_locations.nil?
      @@wrong_guesses << guess
      @@appeals += 1
    else
      @@current_str = reveal_letters(@@current_str, guess, guess_locations)
    end
    if @@win || @@appeals == 5
      setup
    end
  end
  erb :game, :locals => {:difficulty => @@difficulty, :word => @@word, :current_str => @@current_str, :wrong_guesses => @@wrong_guesses, :appeals => @@appeals}
end
