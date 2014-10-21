Rails.application.routes.draw do
  resources :buy
  mount Payola::Engine => "/subdir/payola", as: :payola
end
