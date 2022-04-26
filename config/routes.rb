Rails.application.routes.draw do
  resources :mr_threads
  resources :subthreads
  devise_for :users
  resources :answers
  resources :questions
  resources :assessments
  resources :users

  get '/next_question', to: 'assessments#show'
  get '/questions/next', to: 'questions#next'
  get '/questions/prev', to: 'questions#prev'

  # get '/browse', to: 'projects#browse'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
