# frozen_string_literal: true

require "authorize_that/version"

require_relative "authorize_that/authorize"
require_relative "authorize_that/policy"

module AuthorizeThat
  class Error < StandardError; end
  # Your code goes here...
end

Authorize = AuthorizeThat::Authorize
