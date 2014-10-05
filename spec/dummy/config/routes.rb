Rails.application.routes.draw do
  resources :buy
  mount Payola::Engine => "/payola"
end
