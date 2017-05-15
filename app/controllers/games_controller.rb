class GamesController < ApplicationController

  API_KEY = '729bedbe-1459-4b1d-83d4-63e34b597e66'

  def generate_grid
    @grid = Array.new(10) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now
  end

def score_and_message
  attempt = params[:trial]
  grid = params[:grid].split('')
  time = Time.now - params[:start_time].to_time
  if included?(attempt.upcase, grid)
    if get_translation(attempt)
      score = compute_score(attempt, time)
      @results = [score, "well done"]
    else
      @results = [0, "not an english word"]
    end
  else
    @results = [0, "not in the grid"]
  end
end

  private

  def get_translation(word)
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{API_KEY}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end

  def included?(guess, grid)
    guess = guess.split('')
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end
end
