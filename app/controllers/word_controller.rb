class WordController < ApplicationController

  def game
    @grid = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    start_time = DateTime.parse(params[:start_time])
    @result = run_game(params[:guess], params[:grid], start_time, end_time)
    @results = {}
    session[:scores] ||= []
    session[:scores] << @result[:score].round(1)
    session[:time_played] = session[:scores].length
    sum = 0
    session[:scores].each do |score|
      sum += score
    end
    average = sum / session[:time_played]

    @results[:score] = session[:scores]
    @results[:average] = average.round(1)
    @results[:time_played] = session[:time_played]


  end

  def included?(guess, grid)
    guess = guess.split('')
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "YOUR_SYSTRAN_API_KEY"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
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
end
