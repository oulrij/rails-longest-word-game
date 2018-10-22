class GamesController < ApplicationController
  def new
    @letters = []
    i = 0
    until i == 10
      @letters << ('A'..'Z').to_a.sample
      i += 1
    end
    @letters
    @start_time = Time.now.to_s
  end

  def score
    session[:score] = 0
    @start_time = DateTime.parse(params[:start_time])
    @end_time = Time.now
    @result = run_game(params[:word], params[:grid].split(''), @start_time, @end_time)
    session[:score] += @result[:score_count]
  end

  private

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    json_data = HTTParty.get(url)
    json_data['found']
  end

  def within_grid?(entry, grid)
    entry = entry.upcase.split('')
    entry.all? do |char|
      entry.count(char) <= grid.count(char)
    end
  end

  def score_count(attempt, start_time, end_time)
    attempt.length * 5.0 / (end_time - start_time)
  end

  def run_game(attempt, grid, start_time, end_time)
    time_taken = end_time - start_time
    score = score_count(attempt, start_time, end_time)
    in_grid = within_grid?(attempt, grid)
    if check_word(attempt)
      { time: time_taken, score_count: in_grid ? score : 0, status: in_grid ? :success : :not_in_grid }
    else
      { time: time_taken, score_count: 0, status: :not_in_dictionary }
    end
  end
end
