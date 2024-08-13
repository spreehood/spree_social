module Spree
  module OauthAccessTokenDecorator
    def self.prepended(base)
      base.belongs_to :resource_owner, polymorphic: true
    end
  end
end

Spree::OauthAccessToken.prepend(Spree::OauthAccessTokenDecorator)