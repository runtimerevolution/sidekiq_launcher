# Sidekiq Launcher

Sidekiq Launcher is a gem that provides a user interface for running Sidekiq jobs without having to access the console.
This readme provides information on how to install and use Sidekiq Launcher, as well as how to configure the gem and contribute to the project.

## Installation

### Requirements
```
Rails >= 7.0
Sidekiq >= 6.5.8
```


### Installing Sidekiq Launcher
Optionally you can place the `sidekiq_launcher-(version).gem` file in your application's folder.

Install the gem:

    $ gem install sidekiq_launcher

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq_launcher'
```

Then execute:

    $ bundle install


You can set up Sidekiq Launcher's UI by mounting its routes in your application's ```config/routes.rb``` file. You can also group the routes in RRTools (optional) by adding this line:

```ruby
mount SidekiqLauncher::Engine => '/sidekiq_launcher', defaults: { group: 'RRTools' }
```

#### NOTE:
Make sure you have [Sidekiq](https://github.com/mperham/sidekiq) installed as well before using this gem.


## Usage

### User Interface
To view the UI, run the following route in your browser:
```
http://your_app_path/sidekiq_launcher
```


### Loading Sidekiq Jobs
By default Sidekiq Launcher will try to find Sidekiq Jobs in two ways:
- By reading classes already loaded in your application. Note that this will not work in a development environment unless you configured it to autoload classes on startup. On the other hand, if you have autoload enabled, you won't need to configure Sidekiq Launcher.
- By looking for Sidekiq job class files in the ```/app/sidekiq``` directory. You can specify one or more paths to direct Sidekiq Launcher to your job files (see section 'Configuring Sidekiq Launcher' below).

<br>

To load a job, you Sidekiq Job classes <u>must</u> follow these rules:
- Descend from ```Sidekiq::Worker```
- Include ```Sidekiq::Job```
- Have a method named ```perform```
- Must <u>not</u> have named parameters.

The easiest way to meet these requirements is to follow the [Sidekiq documentation](https://github.com/sidekiq/sidekiq/wiki/Getting-Started).

In there you can find a sample job which meets all these requirements:
```ruby
class HardJob
  include Sidekiq::Job

  def perform(name, count)
    # do something
  end
end
```


### Defining Job Parameters
Sidekiq Launcher incorporates RBS and YARD docs support. Job parameter types are automatically defined if properly outlined with either of these gems.
If your project does not include any of these gems, parameter types will have to be chosen when running Sidekiq jobs through the UI.

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

Note that all paths should be specified individually. Child paths will not be considered.

Paths should be set up relative to your Rails application. The best way to do this is to use ```Railks.root.join()```.
Below is a sample initializer you can use as an example for your project:

```ruby
# your_app/config/initializers/sidekiq_launcher.rb

# frozen_string_literal: true

SidekiqLauncher.configure do |config|
  config.job_paths = [Rails.root.join('app', 'sidekiq_jobs'),
                      Rails.root.join('app', 'sidekiq_jobs', 'module_b'),
                      Rails.root.join('app', 'sidekiq_jobs', 'module_c')]
end
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