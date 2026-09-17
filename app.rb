require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  set :host_authorization, { permitted_hosts: [] }

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    # NOTE: don't change next line - it's needed by autograder!
    word = params[:word] || WordGuesserGame.get_random_word
    # NOTE: don't change previous line - it's needed by autograder!

    @game = WordGuesserGame.new(word)
    redirect '/show'
  end

  post '/guess' do
    letter = params[:guess].to_s[0]

    begin
      valid = @game.guess(letter)

      unless valid
        flash[:message] = "You have already used that letter."
      end
    rescue ArgumentError
      flash[:message] = "Invalid guess."
    end

    redirect '/show'
  end

  get '/show' do
    status = @game.check_win_or_lose

    if status == :win
      redirect '/win'
    elsif status == :lose
      redirect '/lose'
    else
      erb :show
    end
  end

  get '/win' do
    unless @game.check_win_or_lose == :win
      redirect '/show'
    end

    erb :win
  end

  get '/lose' do
    unless @game.check_win_or_lose == :lose
      redirect '/show'
    end

    erb :lose
  end
end
