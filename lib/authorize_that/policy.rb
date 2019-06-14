class AuthorizeThat::Policy
  class << self
    alias allows new
  end

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def to(action, *args)
    public_send("can_#{action}?", *args)
  end
end
