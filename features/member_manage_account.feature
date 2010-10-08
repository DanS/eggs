Feature: Member Manages an Account
  As a Member
  In order to pay for orders
  I want to manage my account

Background:
  Given there is a farm
  Given I am the registered member user benbrown@kathrynaaker.com
  Given there is a "open" delivery "Mission / Potrero"
  And I am on login
  When I login with valid credentials
  Then I should see "Welcome"


Scenario: See a positive account balance
  Given I have a balance of "12"
  When I go to home
  Then I should see "Mission / Potrero"
  Then I should see "Credit: $12.00"

  Scenario: See a negative account balance
    Given I have a balance of "-12"
    When I go to home
    Then I should see "Mission / Potrero"
    Then I should see "$-12.00"
    And I should not see "Credit:"
