# InvisibleController

This gem is to speed up development in restful applications.  If you are using standard rails best practices and naming conventions, controllers are no longer neccessary.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'invisible_controller'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install invisible_controller

## Usage

To use this gem just start deleting your controllers, or don't make them to begin with.  If you find that you need some control over your controllers, or if you have nested routes, define your controllers as normal but have them inherit from InvisibleController::Base.

```ruby
class SomeController < InvisibleController::Base
  belongs_to: some_model, shallow: true, as :some_other_name
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/transcon/invisible_controller.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
