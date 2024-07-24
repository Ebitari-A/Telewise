Rails.application.routes.draw do
  post 'progresses/create'
  get 'user/show'
  devise_for :users
  resources :users, only: :show do
    resources :followed_shows, only: [:index, :new, :create, :destroy]
    resources :notifications, only: [:update]
  end
  # devise_for :users, :controllers => {
  #   registrations: 'users/registrations',
  #   sessions: 'users/sessions'
  # }
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#new_guest'
  end
  resources :notifications
  get 'account', to: 'user#show'
  root to: 'pages#home'
  resources :shows, only: [:index, :show] do
    resources :season_summaries, only: [:index]
    resources :reviews, only: [:create]
  end
  delete 'reviews/:id', to: 'reviews#destroy', as: :review

  # Catch-all route to handle requests not matched above
  get '*path', to: 'application#render_404'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
