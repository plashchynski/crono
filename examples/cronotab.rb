# cronotab.rb — Crono configuration example file
#
# Here you can specify periodic jobs and their schedule.
# You can specify a periodic job as a ActiveJob class in `app/jobs/`
# Actually you can use any class. The only requirement is that
# the class should implement a method `perform` without arguments.
#

class TestJob
  def perform
    puts "Test!"
  end
end

Crono.perform(TestJob).every 5.second
