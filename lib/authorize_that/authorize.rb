# frozen_string_literal: true

module AuthorizeThat
  # :nodoc:
  class Authorize
    # :nodoc:
    class PolicyProxy
      attr_reader :policy

      def initialize(policy_class, user)
        @policy = policy_class.new(user)
      end

      private

      def check_policy_rule(rule, *args)
        policy_method_name = "#{rule}?"
        raise UnknownPolicyRuleError unless policy.respond_to?(policy_method_name)

        policy.public_send(policy_method_name, *args)
      end

      def method_missing(method_name, *args)
        if method_name.to_s.start_with?("can_") && method_name.to_s.end_with?("!") # rubocop:disable Style/GuardClause
          check_policy_rule(method_name.to_s.sub(/!\z/, ""), *args) or raise AuthorizeThat::Policy::RuleNotMetError
        elsif method_name.to_s.start_with?("can_")
          check_policy_rule(method_name, *args)
        else
          super
        end
      end

      def respond_to_missing?(name, _include_private)
        name.to_s.start_with?("can_") || super
      end
    end

    class << self
      attr_accessor :default_policy

      def that(user)
        raise MissingDefaultPolicyError unless default_policy

        new(default_policy).that(user)
      end

      def using(policy_class)
        new(policy_class)
      end
    end

    def initialize(policy_class)
      @policy_class = policy_class
    end

    def that(user)
      PolicyProxy.new(@policy_class, user)
    end
  end
end
