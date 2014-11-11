Payola::Engine.routes.draw do
  match '/buy/:product_class/:permalink' => 'transactions#create',   via: :post, as: :buy
  match '/confirm/:guid'                 => 'transactions#show',     via: :get,  as: :confirm
  match '/status/:guid'                  => 'transactions#status',   via: :get,  as: :status

  match '/subscribe/:plan_class/:plan_id' => 'subscriptions#create',   via: :post, as: :subscribe
  match '/confirm_subscription/:guid'     => 'subscriptions#confirm',     via: :get,  as: :confirm_subscription
  match '/subscription/:guid'     => 'subscriptions#show',     via: :get,  as: :subscription
  match '/subscription_status/:guid'      => 'subscriptions#status',   via: :get,  as: :subscription_status
  match '/cancel_subscription/:guid'     => 'subscriptions#cancel',    via: :get,  as: :cancel_subscription
  match '/cancel_subscription/:guid'     => 'subscriptions#destroy',   via: :delete

  mount StripeEvent::Engine => '/events'
end
