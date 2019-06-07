# AuthorizeThat

## Policies

```ruby
class PostPolicy < Authorize::BasePolicy
  def can_create_post?
    user.confirmed?
  end

  def can_update_post?(post)
    user.admin? || post.owner == user
  end
end

PostPolicy.allows(user).to(:create_post)
# is same as calling
PostPolicy.new(user).can_create_post?

PostPolicy.allows(user).to(:update_post, post)
# is same as calling
PostPolicy.new(user).can_update_post?(post)
```

## Usage Examples

### Only one policy

```ruby
Authorize.policy = SomePolicy

Authorize.that(user).can_create_post
Authorize.that(user).can_update_post(post)
Authorize.that(user).can_delete_post(post)

Authorize.that(admin).can_update_posts
Authorize.that(admin).can_delete_posts
```

### Or default policy

```ruby
Authorize.policy = SomePolicy

Authorize.using(SomeOtherPolicy).that(user).can_update_post(post)
```

### Multiple policies

```ruby
authorize = Authorize.new(PostPolicy)

authorize.that(user).can_create_post
authorize.that(user).can_update_post(post)

authorize = Authorize.new(PostAsAdminPolicy)

authorize.that(admin).can_create_post
authorize.that(admin).can_update_posts
authorize.that(admin).can_delete_posts
authorize.that(admin).can_update_post(post)

authorize = Authorize.new(AdminPolicy)

authorize.that(admin).can_ban(user)
authorize.that(admin).can_drop_the_database # :)
```

### Rails

```ruby

class ApplicationController < ActionController::Base
  include AuthorizeThat::ControllerHelpers
end

class PostsController < ApplicationController
  def create
    authorize_that(current_user).can_create_post
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end

  def update
    @post = Post.find(params[:id])
    authorize_that(current_user).can_update_post(@post)
    if @post.save
      redirect_to @post
    else
      render :edit
    end
  end
end

class StranglyNamedController < ApplicationController
	def update
    	@post = Post.find(params[:id])
		authorize_that(current_user).can_update_post(@post)
		if @post.save
			redirect_to @post
		else
			render :edit
		end
	end

	private

	# custom policy, #{controller_name.singular.camelize}Policy by default
	def policy
	   PostPolicy
	end
	# helper_method :policy

	# def authorize_that(user)
	#   Authorize.using(policy).that(user)
	# end
	# helper_method :authorize_that
end
```

Automatically returns unauthorized response, if you want to change it

```ruby
class SomeController < ApplicationController
  rescue_from_unauthorized_response with: :custom_unauthorized_response

  ...

  private

  def custom_unauthorized_response
    redirect_to root_path, alert: "You are doing something nasty!"
  end
end
```
#### Alternative syntax in Rails controllers

```ruby
authorize_that current_user, :can_create_post
authorize_that current_user, :can_update_post, @post
authorize_that current_user, :can_delete_post, @post

authorize_that current_admin, :can_update_posts
authorize_that current_admin, :can_delete_posts
```

## Resources

* https://www.varvet.com/blog/simple-authorization-in-ruby-on-rails-apps
* https://github.com/varvet/pundit
* https://github.com/cancancommunity/cancancan
