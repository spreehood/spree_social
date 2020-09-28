Spree::Core::Engine.add_routes do
  devise_for :spree_user,
             class_name: Spree::User,
             only: [:omniauth_callbacks],
             controllers: { omniauth_callbacks: 'spree/omniauth_callbacks' },
             path: Spree::SocialConfig[:path_prefix]
  resources :user_authentications

  get 'account' => 'users#show', as: 'user_root'

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      use_doorkeeper do
        skip_controllers 'spree/omniauth_callbacks#login'
      end
      devise_scope :spree_user do
        post '/spree_oauth/social_login/:provider', to: 'omniauth_callbacks#login'
      end
    end
  end
end