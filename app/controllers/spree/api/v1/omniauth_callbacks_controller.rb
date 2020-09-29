
  class Spree::Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Spree::Core::ControllerHelpers::Common
    include Spree::Core::ControllerHelpers::Order
    include Spree::Core::ControllerHelpers::Auth
    include Spree::Core::ControllerHelpers::Store
    skip_before_action :verify_authenticity_token

    def login
      eligible_providers = SpreeSocial::OAUTH_PROVIDERS.map { |p| p[1] if p[2] == 'true' }.compact

      if !(eligible_providers.include?(auth_hash['provider']))
        render json: {error: I18n.t('devise.omniauth_callbacks.provider_not_found', kind: auth_hash['provider'])}, status: :unprocessable_entity
        return
      end

      authentication = Spree::UserAuthentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])

      if authentication.present? && authentication.try(:user).present?
        render json: access_token(authentication.user).body, status: :ok
      elsif spree_current_user
        spree_current_user.apply_omniauth(auth_hash)
        spree_current_user.save!
        render json: access_token(spree_current_user).body, status: :ok
      else
        user = Spree::User.find_by_email(auth_hash['info']['email']) || Spree::User.new
        user.apply_omniauth(auth_hash)
        if user.save
          render json: access_token(user).body, status: :ok
        else
          render json: { error: I18n.t('spree.user_was_not_valid') }, status: :error
        end
      end
    end

    def access_token(user)
      access_token = Doorkeeper::AccessToken.create!({
        resource_owner_id: user.id,
        expires_in: Doorkeeper.configuration.access_token_expires_in,
        use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
      })
      Doorkeeper::OAuth::TokenResponse.new(access_token)
    end

    def auth_hash
      params[:omniauth_callback]
    end
  end


