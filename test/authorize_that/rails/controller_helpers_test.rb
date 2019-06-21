# frozen_string_literal: true

require "test_helper"

class AuthorizeThat::Rails::ControllerHelpersTest < Minitest::Test
  class PostsController < ActionController::Base
    include AuthorizeThat::Rails::ControllerHelpers
    def create
      authorize.that(Object.new).can_create_post
    end

    def delete_all_posts
      authorize.that(Object.new).can_delete_all_posts!
    end
  end

  class PostPolicy < AuthorizeThat::Policy
    def can_create_post?
      true
    end

    def can_delete_all_posts?
      false
    end
  end

  module MyNamespace
    class SomeController < ActionController::Base
      include AuthorizeThat::Rails::ControllerHelpers

      def do_something
        authorize.that(Object.new).can_do_something
      end
    end

    class SomePolicy < AuthorizeThat::Policy
      def can_do_something?
        true
      end
    end
  end

  class CustomPolicyController < ActionController::Base
    include AuthorizeThat::Rails::ControllerHelpers
    authorize_using PostPolicy

    def create
      authorize.that(Object.new).can_create_post
    end
  end

  def test_authorize_that_method_gets_delegated_to_default_policy
    policy = MiniTest::Mock.new
    policy.expect(:can_create_post?, true)
    PostPolicy.stub :new, policy do
      PostsController.new.create
    end
    policy.verify

    policy = MiniTest::Mock.new
    policy.expect(:can_do_something?, true)
    MyNamespace::SomePolicy.stub :new, policy do
      MyNamespace::SomeController.new.do_something
    end
    assert policy.verify
  end

  def test_authorize_that_method_gets_delegated_to_custom_policy_if_defined
    policy = MiniTest::Mock.new
    policy.expect(:can_create_post?, true)
    PostPolicy.stub :new, policy do
      CustomPolicyController.new.create
    end
    assert_mock policy
  end
end
