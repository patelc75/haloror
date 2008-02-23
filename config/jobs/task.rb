# This class is an example only - normally the methods would exist in
# your models or lib directory
class SampleRufusClass
  def self.log
    puts "[SampleRufusClass] running at #{Time.now}"
  end
end

SCHEDULER.schedule_every('2s') { SampleRufusClass.log }
