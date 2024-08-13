module SpreeSocial
  module Admin
    module MainMenu
      class SocialBuilder
        include ::Spree::Core::Engine.routes.url_helpers

        def build
          item = Spree::Admin::MainMenu::ItemBuilder.new('spree_social.authentication_methods', admin_authentication_methods_path)
                                                     .with_match_path('/authentication_methods')
                                                     .build

          Spree::Admin::MainMenu::SectionBuilder.new('social', 'globe.svg')
                                                .with_item(item)
                                                .build
        end
      end
    end
  end
end
