Feature: Bundle job
  In order to process the bundled job from device
  As a system user
  I want to automate the process of data input from bundle file

  Scenario: Load the bundle file and verify data
    Given a user exists with the following attributes:
      | id | 44 |
    And a device exists with the following attributes:
      | id | 965 |
    When I process the bundle job "spec/H200000023_1240876150.tar.bz2"
    Then I should have the following counts of data:
      | batteries         | 94 |
      | battery unplugged | 1  |
      | vitals            | 93 |
      | steps             | 93 |
      | skin temps        | 93 |
