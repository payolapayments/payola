Rails.application.routes.draw do
  resources :buy
  get 'subscribe' => 'subscribe#index'
  mount Payola::Engine => "/subdir/payola", as: :payola
end
