require "test_helper"

class AuthorizeWithSinglePolicyTest < MiniTest::Test
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
    Authorize.policy = MyPolicy

    @user = OpenStruct.new
    @post = OpenStruct.new(editable?: true)
  end

  def test_that_it_can_authorize_using_assigned_policy
    assert Authorize.that(@user).can_create_post
  end

  def test_that_it_can_not_authorize_using_other_policies
    assert_raises NoMethodError do
      Authorize.that(@user).can_edit_post(@post)
    end
  end

  def test_that_it_can_authorize_using_other_policies_by_defining_it_explicitely
    assert Authorize.using(MyOtherPolicy).that(@user).can_edit_post(@post)

    @post.stub :editable?, false do
      refute Authorize.using(MyOtherPolicy).that(@user).can_edit_post(@post)
    end
  end

  def test_that_it_can_not_authorize_using_default_policy_if_other_policy_is_in_use
    assert_raises NoMethodError do
      Authorize.using(MyOtherPolicy).that(@user).can_create_post
    end
  end

  def test_that_defining_policy_to_use_does_not_overwrites_default_policy_globally
    assert Authorize.that(@user).can_create_post
    assert Authorize.using(MyOtherPolicy).that(@user).can_edit_post(@post)
    assert Authorize.that(@user).can_create_post
    assert_raises NoMethodError do
      Authorize.that(@user).can_edit_post(@post)
    end

    Authorize.using(MyOtherPolicy)
    assert Authorize.that(@user).can_create_post
    assert_raises NoMethodError do
      Authorize.that(@user).can_edit_post(@post)
    end
  end
end
