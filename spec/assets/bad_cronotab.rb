# This is an example of a bad cronotab for tests

class TestJob
  def perform
    puts 'Test!'
  end
end

# This is an error, because you can use `on` options with
# a period less than 7 days.

Crono.perform(TestJob).every 5.days, on: :sunday
