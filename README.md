Crono — Job scheduler for Rails
------------------------
[![Build Status](https://travis-ci.org/plashchynski/crono.svg?branch=master)](https://travis-ci.org/plashchynski/crono)
[![Code Climate](https://codeclimate.com/github/plashchynski/crono/badges/gpa.svg)](https://codeclimate.com/github/plashchynski/crono)
[![security](https://hakiri.io/github/plashchynski/crono/master.svg)](https://hakiri.io/github/plashchynski/crono/master)
[![Gem Version](https://badge.fury.io/rb/crono.svg)](http://badge.fury.io/rb/crono)

Crono is a time-based background job scheduler daemon (just like Cron) for Ruby on Rails. It's pure Ruby. It doesn't use Unix Cron and other platform-dependent things. So you can use it everywhere.


## Requirements

Tested with latest MRI Ruby (2.2, 2.1 and 2.0) and Rails 3.2+
Other versions are untested but might work fine.


## Installation

Add the following line to your application's Gemfile:

    gem 'crono'

Run the bundle command to install it.
After you install Crono, you can run the generator:

    rails generate crono:install

It will create a configuration file `config/cronotab.rb`
Now you are ready to move forward to create a job and schedule it.


## Usage

#### Create Job

Crono can use Active Job jobs in `app/jobs/`. The only requirements is that the `perform` method should take no arguments.

Here's an example of a test job:
app/jobs/test_job.rb

    class TestJob < ActiveJob::Base
      def perform
        # put you scheduled code here
        # Comments.deleted.clean_up...
      end
    end

The Active Job jobs is convenient because you can use one class in both periodic and enqueued ways. But it doesn't necessarily. Any class can be used as Job if it has a method `perform` without arguments:

    class TestJob # this is not active job class
      def perform
        # put you scheduled code here
        # Comments.deleted.clean_up...
      end
    end


#### Schedule Jobs

The schedule described in the configuration file `config/cronotab.rb`, that we created using `rails generate crono:install` or manually. The semantic is pretty straightforward:

    Crono.perform(TestJob).every 2.days, at: "15:30"

You can schedule one job a few times if you want the job to be performed a few times a day:

    Crono.perform(TestJob).every 1.days, at: "00:00"
    Crono.perform(TestJob).every 1.days, at: "12:00"

The `at` can be a Hash:

    Crono.perform(TestJob).every 1.days, at: {hour: 12, min: 15}


#### Run daemon

To run Crono daemon, in your Rails project root directory:

    bundle exec crono RAILS_ENV=development


## License

Copyright 2015 Dzmitry Plashchynski <plashchynski@gmail.com>  
Licensed under the Apache License, Version 2.0  
Please see [LICENSE](https://github.com/plashchynski/crono/blob/master/LICENSE) for licensing details.