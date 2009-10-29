class RenameRecordsInSelfTestStepDescriptions < ActiveRecord::Migration
  def self.up
    @self_test_step_description = SelfTestStepDescription.find(9)
    @self_test_step_description.update_attributes(:description => 'Self Test Chest Strap/Belt Clip Complete')
    @self_test_step_description = SelfTestStepDescription.find(10)
    @self_test_step_description.update_attributes(:description => 'Self Test Chest Strap/Belt Clip Failed')
    @self_test_step_description = SelfTestStepDescription.find(11)
    @self_test_step_description.update_attributes(:description => 'Self Test Chest Strap/Belt Clip Timeout')
  end

  def self.down
    @self_test_step_description = SelfTestStepDescription.find(9)
    @self_test_step_description.update_attributes(:description => 'Self Test Chest Strap Complete')
    @self_test_step_description = SelfTestStepDescription.find(10)
    @self_test_step_description.update_attributes(:description => 'Self Test Chest Strap Failed')
    @self_test_step_description = SelfTestStepDescription.find(11)
    @self_test_step_description.update_attributes(:description => 'Self Test Chest Strap Timeout')
  end
end
