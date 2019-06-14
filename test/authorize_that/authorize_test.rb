require "test_helper"

class AuthorizeThat::AuthorizeTest < MiniTest::Test
  class MyPolicy < AuthorizeThat::Policy
    def can_create_post?
      true
    end
  end

  class MyOtherPolicy < AuthorizeThat::Policy
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
    assert authorize.that(@user).is_a?(AuthorizeThat::Authorize::PolicyProxy)
    assert authorize.that(@user).policy.is_a?(MyPolicy)
  end

  def test_that_proper_method_is_sent_from_proxy_to_real_policy
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
end
