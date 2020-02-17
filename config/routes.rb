Rails.application.routes.draw do
  root to: 'games#home'
  get 'new', to: 'games#new', as: :new
  get 'score', to: 'games#score', as: :score
  delete 'clear', to: 'games#clear', as: :clear
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
