# frozen_string_literal: true

require "test_helper"

class AuthorizeWithMultiplePoliciesTest < MiniTest::Test
  class MyPolicy < AuthorizeThat::Policy
    def can_create_post?
      user.active?
    end
  end

  class MyOtherPolicy < AuthorizeThat::Policy
    def can_edit_post?(post)
      user.active? && post.editable?
    end
  end

  def setup
    Authorize.default_policy = MyPolicy

    @active_user = OpenStruct.new(active?: true)
    @inactive_user = OpenStruct.new(active?: false)
    @post = OpenStruct.new(editable?: true)
  end

  def test_that_it_authorize_using_default_policy_if_policy_is_not_defined
    assert Authorize.that(@active_user).can_create_post, "Active user should be able to create post"
    assert !Authorize.that(@inactive_user).can_create_post, "Inactive user should not be able to create post"

    assert_equal MyPolicy, Authorize.that(@active_user).policy.class
  end

  def test_that_it_can_not_authorize_using_other_policies_unless_used_explicitely
    assert_raises AuthorizeThat::UnknownPolicyRuleError do
      Authorize.that(@active_user).can_edit_post(@editable_post)
    end
  end

  def test_that_it_can_authorize_using_other_policies_by_defining_it_explicitely
    assert Authorize.using(MyOtherPolicy).that(@active_user).can_edit_post(@post), "Active user can edit post"
    assert !Authorize.using(MyOtherPolicy).that(@inactive_user).can_edit_post(@post), "Inactive user can not edit post"

    assert_equal MyOtherPolicy, Authorize.using(MyOtherPolicy).that(@active_user).policy.class
  end

  def test_that_it_can_not_authorize_using_default_policy_if_other_policy_is_in_use
    assert_raises AuthorizeThat::UnknownPolicyRuleError do
      Authorize.using(MyOtherPolicy).that(@active_user).can_create_post
    end
  end

  def test_that_defining_policy_to_use_does_not_overwrites_default_policy_globally
    assert Authorize.that(@active_user).can_create_post, "Active user can create post"
    assert Authorize.using(MyOtherPolicy).that(@active_user).can_edit_post(@post), "Active user can edit post"
    assert Authorize.that(@active_user).can_create_post, "Active user can create post"
    assert_equal MyPolicy, Authorize.that(@active_user).policy.class

    Authorize.using(MyOtherPolicy)
    assert Authorize.that(@active_user).can_create_post
    assert_equal MyPolicy, Authorize.that(@active_user).policy.class
  end

  def test_that_it_raises_rule_not_met_error_instead_of_returning_false_when_checking_with_bang_method
    assert Authorize.that(@active_user).can_create_post!, "Active user can create post"
    assert Authorize.using(MyOtherPolicy).that(@active_user).can_edit_post!(@post), "Active user can edit post"

    assert_raises AuthorizeThat::Policy::RuleNotMetError do
      Authorize.that(@inactive_user).can_create_post!
    end
    assert_raises AuthorizeThat::Policy::RuleNotMetError do
      Authorize.using(MyOtherPolicy).that(@inactive_user).can_edit_post!(@post)
    end
  end
end
