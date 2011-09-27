@L1 @critical
Feature: Bundle job
  In order to process the bundled job from device
  As a system user
  I want to automate the process of data input from bundle file
                             
  Background:
    Given a user exists with the following attributes:
      | id | 44 |
    And a device exists with the following attributes:
      | serial_number | 1234567890 |
  
  # FIXME: some error, but not in scope for now. will fix after user intake
  @wip
  Scenario: Load the bundle file and verify data
    When I process the bundle job "spec/H200000023_1240875421.tar.bz2"
    And I should have the following counts of data:
      | batteries               | 93 |
      | battery unplugged       | 1  |
      | vitals                  | 93 |
      | steps                   | 92 |
      | skin temps              | 92 |
      | oscope msgs             | 4  |
      | points                  | 4  |
      | dial up statuses        | 4  |
      | dial up last successful | 1  | 
      | bundles                 | 10 |         
    And I do not see "dialup/H200000023_1240875421" folder 
      
  Scenario Outline: Verify OScopeMsg XML with & without points
    When I process the xml file "spec/data/oscope_msg_<part_name>.xml"
    Then I should have the following counts of data:
      | oscope msgs       | <oscope> |
      | points            | <points> |
      | oscope start msgs | <starts> |  
      | oscope stop msgs  | <stops>  |        
  
    Examples:
      | part_name | oscope | points | starts | stops |
      | points    | 2      | 4      | 0      | 0     |
      | no_points | 2      | 0      | 1      | 1     |

  Scenario: Dial Up Status XML
    When I process the xml file "spec/data/dial_up_status.xml"
    Then I should have the following counts of data:
      | dial up statuses        | 4 |
      | dial up last successful | 1 |
    And all dial up statuses should have username and password

  Scenario: OscopeStartMsg link to OscopeMsg
    When I process the xml file "spec/data/oscope_start_msg.xml"
    And I process the xml file "spec/data/oscope_msg_points.xml"
    Then I should have the following counts of data:
      | oscope msgs             | 2  |
      | points                  | 4  |
      | oscope start msgs       | 1  |
    And last oscope_start_msg should at least have 2 oscope_msgs

  @wip
  Scenario Outline: Simulate gateway with CURL
    Given a gateway exists with the following attributes:
      | id | 0 |
    When I process the curl text file "spec/data/curl/<file_name>.txt"
    Then I should have the following counts of data:
      | batteries               | <bat>       |
      | battery unplugged       | <unplug>    |
      | vitals                  | <vital>     |
      | steps                   | <step>      |
      | skin temps              | <skin>      |
      | oscope msgs             | <oscope>    |
      | points                  | <point>     |
      | dial up statuses        | <dial>      |
      | dial up last successful | <dial_last> |

    Examples:
      | file_name   | bat | unplug | vital | step | skin | oscope | point | dial | dial_last |
      | oscope_msgs |     |        |       |      |      | 2      | 4     |      |           |
