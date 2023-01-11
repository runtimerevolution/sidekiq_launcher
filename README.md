# Sidekiq Launcher

Sidekiq Launcher provides a User Interface to run Sidekiq jobs without the need of accessing the console.

## Installation

### Requirements
```
Rails >= 7.0
Sidekiq >= 6.5.8
```


### Installing Sidekiq Launcher
Optionally you can place the `sidekiq_launcher-(version).gem` file in your application's folder.

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq_launcher'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sidekiq_launcher

Set up Sidekiq Launcher's UI by mounting its routes in your application's ```config/routes.rb```file:
```ruby
mount SidekiqLauncher::Engine => '/sidekiq_launcher'
```

#### NOTE:
Make sure you have [Sidekiq](https://github.com/mperham/sidekiq) installed as well before using this gem.


## Usage

### User Interface
To view the UI, simply run the route in your browser:
```
http://your_app_path/sidekiq_launcher
```


### Loading Sidekiq Jobs
By default Sidekiq Launcher will try to find Sidekiq Jobs in two ways:
- By reading classes already loaded in your application. Note that this will <u>not</u> work in a development environment unless you configured it to autoload classes on startup;
- Sidekiq Job class files placed in the '/app/sidekiq' diretory. You can specify one or more paths to direct Sidekiq Launcher to your Job files (see section 'Configuring Sidekiq Launcher' below).


### Defining Job Parameters
Sidekiq Launcher incorporates RBS and Yard docs support. Job parameter types are automatically defined if properly outlined with either of these gems.
If your project does not include any of these gems, parameter types will have to be chosen when running Sidekiq Jobs through the UI.


## Sidekiq Launcher Configuration

### Setting Up Paths
You can configure Sidekiq Launcher to load Sidekiq Jobs from specific paths:
```ruby
SidekiqLauncher.configure do |config|
  config.job_paths = some_path || [array, of, paths]
end
```

or

```ruby
config = SidekiqLauncher::Configuration.new
config.job_paths = some_path || [array, of, paths]
SidekiqLauncher.configuration = config
```


### Reading Job Paths
```ruby
config.job_paths # => ''

SidekiqLauncher.configuration.job_paths # => ''
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/runtimerevolution/sidekiq_launcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/runtimerevolution/sidekiq_launcher/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).