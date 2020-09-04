# frozen_string_literal: true

require "test_helper"

class AuthorizeThat::AuthorizeTest < MiniTest::Test
  class MyPolicy < AuthorizeThat::Policy
    def can_edit_post?(post)
      post.editable?
    end
  end

  def setup
    @user = OpenStruct.new
    @post = OpenStruct.new(editable?: true)
  end

  def test_that_method_returns_proper_policy_proxy
    authorize = Authorize.new(MyPolicy)
    assert authorize.that(@user).policy.is_a?(MyPolicy)
  end

  def test_that_proper_method_is_sent_to_policy
    policy = Minitest::Mock.new
    policy.expect(:can_create_post?, true)
    policy_class = Minitest::Mock.new
    policy_class.expect(:new, policy, [@user])

    authorize = Authorize.new(policy_class)
    authorize.that(@user).can_create_post

    assert_mock policy_class
    assert_mock policy

    policy.expect(:can_edit_post?, true, [@post])
    policy_class.expect(:new, policy, [@user])
    authorize.that(@user).can_edit_post(@post)

    assert_mock policy_class
    assert_mock policy
  end

  def test_that_calling_bang_method_raises_not_authorized_error_instead_of_returning_false
    authorize = Authorize.new(MyPolicy)
    assert authorize.that(@user).can_edit_post(@post)
    assert authorize.that(@user).can_edit_post!(@post)

    @post.stub(:editable?, false) do
      assert_raises AuthorizeThat::Policy::RuleNotMetError do
        authorize.that(@user).can_edit_post!(@post)
      end
    end
  end
end
