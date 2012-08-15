Brushup::Application.routes.draw do
  root :to => 'sessions#index'
  resources :sessions

  match "login" => "sessions#index"
  match "logout" => "sessions#destroy"
  match "info" => "sessions#index"

  match ':user/sessions/:action', :controller => "sessions"

  match 'timelines' => "timelines#list"
  match 'timelines/:action' => "timelines#:action"
  match 'timelines/show/:id' => "timelines#show"
  match 'timelines/:action(/:tag)' => "timelines#:action"

  match ':user' => "reminders#index"
  match ':user/list(/:tag)' => "reminders#list"
  match ':user/today(/:tag)' => "reminders#today"
  match ':user/completed(/:tag)' => "reminders#completed"
  match ':user/list(/:tag)' => "reminders#list"
  match ':user/today(/:tag)' => "reminders#today"
  match ':user/completed(/:tag)' => "reminders#completed"
  match ':user/:action/:id', :controller => "reminders"
  match ':user/:action', :controller => "reminders"

  match ':controller(/:action(/:id))(.:format)'
end
