
  class Spree::Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Spree::Core::ControllerHelpers::Common
    include Spree::Core::ControllerHelpers::Order
    include Spree::Core::ControllerHelpers::Auth
    include Spree::Core::ControllerHelpers::Store
    skip_before_action :verify_authenticity_token


    def login
      # Check for valid provider or not
      authentication = Spree::UserAuthentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
      if authentication.present? and authentication.try(:user).present?
        # sign in the user and return the tokens
        sign_in(authentication.user)
      elsif spree_current_user
        spree_current_user.apply_omniauth(auth_hash)
        spree_current_user.save!
        # Return the access token
      else
        user = Spree::User.find_by_email(auth_hash['info']['email']) || Spree::User.new
        user.apply_omniauth(auth_hash)
        if user.save
          # sign in the user and return the access token
        else
          # Show that the user is not present in the system and send to registration page
        end
      end
    end

    def auth_hash
      params[:omniauth_callback]
    end
  end


