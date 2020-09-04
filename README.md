# AuthorizeThat

Super simple authorization library for Ruby apps.

## Policies

```ruby
class PostPolicy < AuthorizeThat::Policy
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


# Auto generated stuff

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/authorize_that`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'authorize_that'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authorize_that

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/authorize_that. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AuthorizeThat project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/authorize_that/blob/master/CODE_OF_CONDUCT.md).

Sponsored by:

[![BetterDoc](bd_logo.png?raw=true)](https://www.betterdoc.org)

