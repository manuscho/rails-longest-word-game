require 'open-uri'
require 'json'
require 'date'

class GamesController < ApplicationController

  def new
    session[:highscore] ||= []

    letter_array = []
    10.times do
      letter_array << ("A".."Z").to_a.sample
    end
    @letters = letter_array
    @start = Time.now.to_f
  end

  def score
    @answer = params[:answer]
    @letters = params[:letters]
    @time = Time.now.to_f - params[:start].to_f
    @score = (params[:answer].length - (@time / 120)).round(2)
    @url = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia.giphy.com%2Fmedia%2FNTY1kHmcLsCsg%2Fgiphy.gif&f=1&nofb=1"

    grid_hash = {}
    ("A".."Z").to_a.each { |letter| grid_hash[letter] = 1 }

    @answer_array = @answer.upcase.split('').sort
    @letters_array = @letters.upcase.split(' ').sort

    @letters_array.each { |letter| grid_hash[letter] += 1 }
    @answer_array.each { |letter| grid_hash[letter] = grid_hash[letter] - 1 }
    allowed = grid_hash.values.all?(&:positive?)

    checker = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{@answer}").read)
    word = checker['found']

    if @answer == ''
      @outcome = 'Cheater! Empty answer! - You loose'
      @score = "LOST"
    elsif word == false && allowed == false
      @outcome = 'Not an allowed word and not even English! - You loose'
      @score = "LOST"
    elsif word == true && allowed == false
      @outcome = 'English word, but not allowed - You loose'
      @score = "LOST"
    elsif word == false && allowed == true
      @outcome = "You are allowed to use this word, but it's not english - You loose"
      @score = "LOST"
    else
      @outcome = "You won with #{@score} points after #{@time.round(2)} seconds"
      @url = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi1.wp.com%2Fbestanimations.com%2FHolidays%2FFireworks%2Ffireworks%2Fba-awesome-colorful-fireworks-animated-gif-image-s.gif&f=1&nofb=1"
    end

    if @score == "LOST"
    else
      session[:highscore] << { "answer" => @answer, "score" => @score }
    end
    @highscore = session[:highscore].sort_by { |hsh| hsh["score"] }.reverse
  end

  def clear
    reset_session
    redirect_to :new
  end
end
