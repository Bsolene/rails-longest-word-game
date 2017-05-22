Rails.application.routes.draw do
  get 'logins/create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

get '/game', to: 'word#game'

get '/score', to: 'word#score'

get '/', to: 'logins#create'


end
