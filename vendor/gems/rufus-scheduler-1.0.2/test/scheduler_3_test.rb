
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'test/unit'
require 'openwfe/util/scheduler'


class Scheduler3Test < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    #
    # Testing tags
    #
    def test_0

        scheduler = OpenWFE::Scheduler.new
        scheduler.start

        value = nil

        scheduler.schedule_in "3s", :tags => "fish" do
            value = "fish"
        end

        sleep 0.300 # let the job get really scheduled

        assert_equal [], scheduler.find_jobs('deer')
        assert_equal 1, scheduler.find_jobs('fish').size

        scheduler.schedule "* * * * *", :tags => "fish" do
            value = "cron-fish"
        end
        scheduler.schedule "* * * * *", :tags => "vegetable" do
            value = "daikon"
        end

        sleep 0.300 # let the jobs get really scheduled

        assert_equal 2, scheduler.find_jobs('fish').size
        #puts scheduler.find_jobs('fish')

        scheduler.find_jobs('fish').each do |job|
            scheduler.unschedule(job.job_id)
        end

        sleep 0.300 # give it some time to unschedule

        assert_equal [], scheduler.find_jobs('fish')
        assert_equal 1, scheduler.find_jobs('vegetable').size

        scheduler.find_jobs('vegetable')[0].unschedule

        sleep 0.300 # give it some time to unschedule

        assert_equal 0, scheduler.find_jobs('vegetable').size
    end

end
