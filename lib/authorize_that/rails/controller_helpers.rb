# frozen_string_literal: true

require "action_controller"

module AuthorizeThat
  module Rails
    # :nodoc:
    module ControllerHelpers
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :authorization_policy

        def authorize_using(policy_class)
          @authorization_policy = policy_class
        end

        def authorization_policy
          @authorization_policy ||= "#{to_s.gsub(/Controller\z/, '').singularize}Policy".constantize
        end
      end

      private

      def authorize
        AuthorizeThat::Authorize.new(self.class.authorization_policy)
      end
    end
  end
end
