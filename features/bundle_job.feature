Feature: Bundle job
  In order to process the bundled job from device
  As a system user
  I want to automate the process of data input from bundle file

  Background:
    Given a user exists with the following attributes:
      | id | 44 |
    And a device exists with the following attributes:
      | id | 965 |
  
  Scenario: Load the bundle file and verify data
    When I process the bundle job "spec/H200000023_1240876150.tar.bz2"
    Then I should have the following counts of data:
      | batteries         | 93 |
      | battery unplugged | 1  |
      | vitals            | 93 |
      | steps             | 92 |
      | skin temps        | 92 |

  Scenario Outline: Verify OScopeMsg XML with & without points
    When I process the xml file "spec/data/oscope_msg_<part_name>.xml"
    Then I should have the following counts of data:
      | oscope msgs | <oscope> |
      | points      | <points> |
  
    Examples:
      | part_name | oscope | points |
      | no_points | 2      | 0      |
      | points    | 2      | 4      |
