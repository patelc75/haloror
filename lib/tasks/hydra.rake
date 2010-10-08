# require 'hydra' # require the hydra codebase
# require 'hydra/tasks' # require the hydra rake task helpers
# 
# # set up a new hydra testing task named 'hydra:units' run with "rake hydra:units"
# Hydra::TestTask.new('hydra:units') do |t|
#   # add all files in the test/unit directory recursively that
#   # end with "_test.rb"
#   t.add_files 'test/unit/**/*_test.rb'
#   # and test/functional
#   t.add_files 'test/functional/**/*_test.rb'
#   # and test/integration
#   t.add_files 'test/integration/**/*_test.rb'
# end
# 
# # set up a new hydra testing task named 'hydra:spec' run with "rake hydra:spec"
# Hydra::TestTask.new('hydra:spec') do |t|
#   # you may or may not need this, depending on how you require
#   # spec_helper in your test files:
#   require 'spec/spec_helper'
#   # add all files in the spec directory that end with "_spec.rb"
#   t.add_files 'spec/**/*_spec.rb'
# end
# 
# # set up a new hydra testing task named 'hydra:cucumber' run with "rake hydra:cucumber"
# Hydra::TestTask.new('hydra:cucumber') do |t|
#   # add all files in the features directory that end with ".feature"
#   t.add_files 'features/**/*.feature'
# end
# 
