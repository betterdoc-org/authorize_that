# frozen_string_literal: true

require "test_helper"

class AuthorizeThat::PolicyTest < Minitest::Test
  class UserPolicy < AuthorizeThat::Policy
    def can_do_something?
      user.confirmed?
    end

    def can_edit_post?(post)
      post.user.object_id == user.object_id
    end

    def standard_method; end

    def can_do_without_questionmark; end

    private

    def can_do_private_stuff?; end
  end

  def setup
    @user = OpenStruct.new(confirmed?: true)
    @post = OpenStruct.new(user: @user)
  end

  def test_allows_class_method_delegates_to_new
    assert UserPolicy.allows(@user).is_a?(UserPolicy)
  end

  def test_to_method_calls_qustionmark_method_prefixed_with_can
    assert UserPolicy.allows(@user).to(:do_something)
    assert UserPolicy.allows(@user).to(:edit_post, @post)

    @user.stub :confirmed?, false do
      refute UserPolicy.allows(@user).to(:do_something)
    end

    @post.user = OpenStruct.new
    refute UserPolicy.allows(@user).to(:edit_post, @post)
  end

  def test_to_method_works_only_for_public_questionmark_methods_that_start_with_can
    assert_raises NoMethodError do
      UserPolicy.allows(@user).to(:standard_method)
    end
    assert_raises NoMethodError do
      UserPolicy.allows(@user).to(:do_without_questionmark)
    end
    assert_raises NoMethodError do
      UserPolicy.allows(@user).to(:do_private_stuff)
    end
  end
end
