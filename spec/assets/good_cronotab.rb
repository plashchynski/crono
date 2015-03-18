# This is an example of a good cronotab for tests

class TestJob
  def perform
    puts 'Test!'
  end
end

Crono.perform(TestJob).every 5.seconds
