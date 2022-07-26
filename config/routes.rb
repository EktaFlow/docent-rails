Rails.application.routes.draw do
  resources :file_attachments
  resources :mr_threads
  resources :subthreads
  # devise_for :users
  resources :answers
  resources :questions
  resources :assessments
  resources :team_members
  # resources :users

  get '/next_question', to: 'assessments#show'
  get '/next_action', to: 'questions#pick_action'

  get '/get_files', to: 'assessments#file_explorer'
  post '/add_to_question', to: 'file_attachments#add_to_question'
  get '/get_assessment', to: 'assessments#grab_base_report'
  get '/grab_criteria', to: 'assessments#grab_criteria_data'
  get '/send_reset', to: 'users#reset_password_request'
  put '/reset_pwd', to: 'users#reset_pwd'
  get '/next_specific_question', to: 'questions#show'

  put '/delete_file_question', to: 'questions#update_files'
  delete '/delete_file_assessment', to: 'file_attachments#destroy'

  put '/update_assessments', to: 'assessments#update'
  get '/get_all_tm', to: 'assessments#get_all_tm'

  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }


  # get '/browse', to: 'projects#browse'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
