# frozen_string_literal: true

require "test_helper"

class AuthorizeWithSinglePolicyTest < MiniTest::Test
  class MyPolicy < AuthorizeThat::Policy
    def can_create_post?
      user.active?
    end
  end

  def setup
    @active_user = OpenStruct.new(active?: true)
    @inactive_user = OpenStruct.new(active?: false)
  end

  def test_that_it_can_authorize_using_default_policy
    Authorize.default_policy = MyPolicy

    assert Authorize.that(@active_user).can_create_post, "Active user should be able to create post"
    assert !Authorize.that(@inactive_user).can_create_post, "Inactive user should not be able to create post"
  end
end
