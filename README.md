Crono — Job scheduler for Rails
------------------------
[![Gem Version](https://badge.fury.io/rb/crono.svg)](http://badge.fury.io/rb/crono)
[![Build Status](https://travis-ci.org/plashchynski/crono.svg?branch=master)](https://travis-ci.org/plashchynski/crono)
[![Code Climate](https://codeclimate.com/github/plashchynski/crono/badges/gpa.svg)](https://codeclimate.com/github/plashchynski/crono)
[![security](https://hakiri.io/github/plashchynski/crono/master.svg)](https://hakiri.io/github/plashchynski/crono/master)

Crono is a time-based background job scheduler daemon (just like Cron) for Ruby on Rails.


## The Purpose

Currently, there is no such thing as Ruby Cron for Rails. Well, there's [Whenever](https://github.com/javan/whenever) but it works on top of Unix Cron, so you can't manage it from Ruby. Crono is pure Ruby. It doesn't use Unix Cron and other platform-dependent things. So you can use it on all platforms supported by Ruby. It persists job states to your database using Active Record. You have full control of jobs performing process. It's Ruby, so you can understand and modify it to fit your needs.

![Web UI](https://github.com/plashchynski/crono/raw/master/examples/crono_web_ui.png)


## Requirements

Tested with latest MRI Ruby 2.2+, 2.3+, Rails 4.\*, Rails 5.\*, and Rails 6.\*.
Other versions are untested but might work fine.


## Installation

Add the following line to your application's Gemfile:

```ruby
gem 'crono'
```

Run the `bundle` command to install it.  
After you install Crono, you can run the generator:

    rails generate crono:install

It will create a configuration file `config/cronotab.rb` and migration  
Run the migration:

    rake db:migrate

Now you are ready to move forward to create a job and schedule it.


## Usage

#### Create Job

Crono can use Active Job jobs from `app/jobs/`. The only requirement is that the `perform` method should take no arguments.

Here's an example of a job:

```ruby
# app/jobs/test_job.rb
class TestJob < ActiveJob::Base
  def perform(options)
    # put you scheduled code here
    # Comments.deleted.clean_up...
  end
end
```

The ActiveJob jobs are convenient because you can use one job in both periodic and enqueued ways. But Active Job is not required. Any class can be used as a crono job if it implements a method `perform`:

```ruby
class TestJob # This is not an Active Job job, but pretty legal Crono job.
  def perform(*args)
    # put you scheduled code here
    # Comments.deleted.clean_up...
  end
end
```

Here's an example of a Rake Task within a job:

```ruby
# config/cronotab.rb
require 'rake'

Rails.app_class.load_tasks

class Test
  def perform(options)
    Rake::Task['crono:hello'].invoke
  end
end

Crono.perform(Test).every 5.seconds
```
With the rake task of:
```Ruby
# lib/tasks/test.rake
namespace :crono do
  desc 'Update all tables'
  task :hello => :environment do
    puts "hello"
  end
end
```

_Please note that crono uses threads, so your code should be thread-safe_

#### Job Schedule

Schedule list is defined in the file `config/cronotab.rb`, that created using `crono:install`. The semantic is pretty straightforward:

```ruby
# config/cronotab.rb
Crono.perform(TestJob).every 2.days, at: {hour: 15, min: 30}
Crono.perform(TestJob).every 1.week, on: :monday, at: "15:30"
```

You can schedule one job a few times if you want the job to be performed a few times a day or a week:

```ruby
Crono.perform(TestJob).every 1.week, on: :monday
Crono.perform(TestJob).every 1.week, on: :thursday
```

The `at` can be a Hash:

```ruby
Crono.perform(TestJob).every 1.day, at: {hour: 12, min: 15}
```

You can schedule a job with arguments, which can contain objects that can be
serialized using JSON.generate

```ruby
Crono.perform(TestJob, 'some', 'args').every 1.day, at: {hour: 12, min: 15}
```

You can set some options that not passed to the job but affect how the job will be treated by Crono. For example, you can set to truncate job logs (which stored in the database) to a certain number of records:

```ruby
Crono.perform(TestJob).with_options(truncate_log: 100).every 1.week, on: :monday
```

#### Run

To run Crono, in your Rails project root directory:

    bundle exec crono RAILS_ENV=development

crono usage:
```
Usage: crono [options] [start|stop|restart|run]
    -C, --cronotab PATH              Path to cronotab file (Default: config/cronotab.rb)
    -L, --logfile PATH               Path to writable logfile (Default: log/crono.log)
    -P, --pidfile PATH               Deprecated! use --piddir with --process_name; Path to pidfile (Default: )
    -D, --piddir PATH                Path to piddir (Default: tmp/pids)
    -N, --process_name NAME          Name of the process (Default: crono)
    -d, --[no-]daemonize             Deprecated! Instead use crono [start|stop|restart] without this option; Daemonize process (Default: false)
    -m, --monitor                    Start monitor process for a deamon (Default false)
    -e, --environment ENV            Application environment (Default: development)
```

#### Run as a daemon

To run Crono as a daemon, please add to your Gemfile:

```ruby
gem 'daemons'
```

Then:

    bundle install; bundle exec crono start RAILS_ENV=development

There are "start", "stop", and "restart" commands.

## Web UI

Crono can display the current state of Crono jobs.  

Add the following to your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
    mount Crono::Engine, at: '/crono'
    ...
```

Access management and other questions described in the [wiki](https://github.com/plashchynski/crono/wiki/Web-UI).

#### Known issues

For Rails 5, in case of the errors:
```
`require': cannot load such file -- rack/showexceptions (LoadError)
```
See the related issue [#52](https://github.com/plashchynski/crono/issues/52)


## Capistrano

Use the `capistrano-crono` gem ([github](https://github.com/plashchynski/capistrano-crono/)).


## Support

Feel free to create [issues](https://github.com/plashchynski/crono/issues)


## Known Issues

* Is not compatible with the `protected_attributes` gem. See: [https://github.com/plashchynski/crono/issues/43](https://github.com/plashchynski/crono/issues/43)


## License

Please see [LICENSE](https://github.com/plashchynski/crono/blob/master/LICENSE) for licensing details.
