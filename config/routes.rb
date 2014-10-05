Payola::Engine.routes.draw do
  match '/buy/:product_class/:permalink' => 'transactions#create',   via: :post, as: :buy
  match '/confirm/:guid'                 => 'transactions#show',     via: :get,  as: :confirm
  match '/status/:guid'                  => 'transactions#status',   via: :get,  as: :status

  mount StripeEvent::Engine => '/events'
end
