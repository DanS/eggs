Feature: Submit Order
  In order for customers to create orders
  They have to submit an order form

Background:
  Given I am the registered user jennyjones
  And I am on login
  When I login with valid credentials
  Then I should see "Successfully logged in"  

Scenario: View Order Form
  When I go to orders/new
  Then I should see "Emeryville - Wednesday"
  And I follow "Emeryville - Wednesday"
  Then I should see "New order"
  And I should see "Emeryville - Wednesday"
  And I should see "Chicken, REGULAR"
  And I should see "Eggs"

Scenario: Submit Order Form With Minimum Order Error
  When I go to orders/new
  And I follow "Emeryville"
  Then I should see "New order"
  And I select "1" from "order_order_items_attributes_1_quantity"
  And I press "Create"
  Then I should see "your order does not meet the minimum"

Scenario: Submit Order Form with Success
  When I go to orders/new
  And I follow "Emeryville"
  Then I should see "New order"
  And I select "2" from "order_order_items_attributes_0_quantity"
  And I press "Create"
  Then I should see "Order was successfully created."
  
Scenario: Edit an Order
  When I go to farms
  And I follow "Soul Food Farm"
  And I follow "Emeryville"
  And I follow "Ben Brown"
  And I follow "edit"
  Then I should see "Emeryville"