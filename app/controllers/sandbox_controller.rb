class SandboxController < ApplicationController
	#layout "application", :except => "chart"

	def helloworld
  end

	def summary
    @avgHeartRate = Heartrate.average('heartRate');
    @maxHeartRate = Heartrate.maximum('heartRate');
    @minHeartRate = Heartrate.minimum('heartRate');
		@currentHeartRate = Heartrate.find(:first, :order => 'timeStamp')
  end
	
	def report
		@heartrates = Heartrate.find(:all)
  end
	
	def chart
  end

	def current
		@recentHeartRate = Heartrate.find(:first, :order => 'id DESC')
		@currentHeartRate = @recentHeartRate.heartRate
  end
end