# frozen_string_literal: true

require "authorize_that/version"

require_relative "authorize_that/authorize"
require_relative "authorize_that/policy"

module AuthorizeThat
  MissingDefaultPolicyError = Class.new(StandardError)
  UnknownPolicyRuleError = Class.new(StandardError)
end

Authorize = AuthorizeThat::Authorize unless defined?(Authorize)
