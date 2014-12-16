Payola::Engine.routes.draw do
  match '/buy/:product_class/:permalink' => 'transactions#create',   via: :post, as: :buy
  match '/confirm/:guid'                 => 'transactions#show',     via: :get,  as: :confirm
  match '/status/:guid'                  => 'transactions#status',   via: :get,  as: :status

  match '/subscribe/:plan_class/:plan_id' => 'subscriptions#create',   via: :post,   as: :subscribe
  match '/confirm_subscription/:guid'     => 'subscriptions#show',     via: :get,    as: :confirm_subscription
  match '/subscription_status/:guid'      => 'subscriptions#status',   via: :get,    as: :subscription_status
  match '/cancel_subscription/:guid'      => 'subscriptions#destroy',  via: :delete, as: :cancel_subscription
  match '/change_plan/:guid'              => 'subscriptions#change_plan', via: :post, as: :change_subscription_plan
  match '/change_quantity/:guid'          => 'subscriptions#change_quantity', via: :post, as: :change_subscription_quantity
  match '/update_card/:guid'              => 'subscriptions#update_card', via: :post, as: :update_card

  mount StripeEvent::Engine => '/events'
end
