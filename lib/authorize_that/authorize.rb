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

      def method_missing(name, *args)
        if name.to_s.start_with?("can_") && name.to_s.end_with?("!")
          policy.public_send("#{name.to_s.sub(/\!\z/, '?')}", *args) or raise AuthorizeThat::Error
        elsif name.to_s.start_with?("can_")
          policy.public_send("#{name}?", *args)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        name.to_s.start_with?("can_") || super
      end
    end

    class << self
      attr_accessor :policy

      def that(user)
        new(policy).that(user)
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
