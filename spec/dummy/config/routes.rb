Rails.application.routes.draw do
  resources :buy
  get 'subscribe' => 'subscribe#index'
  post 'subscribe' => 'subscribe#create'
  get 'subscription/:guid' => 'subscribe#show'
  mount Payola::Engine => "/subdir/payola", as: :payola
  root 'home#index'
  post '' => 'home#index'
end
