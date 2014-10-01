Payola::Engine.routes.draw do
  match '/buy/:product_class/:permalink' => 'transactions#new',      via: :get,  as: :show_buy
  match '/buy/:product_class/:permalink' => 'transactions#create',   via: :post, as: :buy
  match '/confirm/:guid'                 => 'transactions#show',     via: :get,  as: :confirm
  match '/pickup/:guid'                  => 'transactions#pickup',   via: :get,  as: :pickup
  match '/iframe/:username/:permalink'   => 'transactions#iframe',   via: :get,  as: :buy_iframe
  match '/status/:guid'                  => 'transactions#status',   via: :get,  as: :status

  mount StripeEvent::Engine => '/events'
end
