require 'spec_helper'

describe Importer do
  before(:each) do
    Factory(:farm)
    @importer = Importer.new
  end

  it "should list pickups" do
    @importer.pickups.size.should == 2
  end
end

describe PickupImport do
  before :each do
    @farm = Factory(:farm)
    @chicken_regular = Factory(:product, :farm => @farm, :name => 'Chicken, REGULAR')
    @import = PickupImport.new "#{RAILS_ROOT}/db/import/SFF CSA 1-13-10 TEST.csv"
  end

  context "Creating Members, Orders and OrderItems" do

    before :each do
      @kathryn = Factory(:member, :first_name => "Kathryn", :last_name => "Aaker", :email_address => 'kathryn@kathrynaaker.com')
    end

    it "should find existing member" do
      kathryn = Factory(:member, :first_name => "Kathryn", :last_name => "Aaker", :email_address => 'kathryn@kathrynaaker.com')
      @import.members.size.should == 2
      @import.members[0].should == @kathryn
      @import.members[0].subscriptions[0].farm.should == @farm
    end

    it "should create new member" do
      @import.members[1].first_name.should == "Alon"
      @import.members[1].last_name.should == "Salant"
      @import.members[1].subscriptions[0].farm.should == @farm
      @import.members[1].new_record?.should == true
    end

    it "should create new orders" do
      @import.orders.size.should == 4
      @import.orders[0].member.should == @kathryn
      @import.orders[0].pickup.name.should == "SF Potrero"
      @import.orders[0].finalized_total.should == 30.55

      @import.orders[1].member.first_name.should == "Alon"
      @import.orders[1].pickup.name.should == "SF Potrero"
    end

    it "should create order items for each stock item" do
      @import.orders[0].order_items.size.should == 8
      @import.orders[0].order_items[0].stock_item.product.should == @chicken_regular
      @import.orders[0].order_items[0].quantity.should == 1
    end

  end

  context "Creating Products, Pickups and StockItems" do
    before :each do
    end

    it "should identify columns" do
      columns = @import.columns
      columns.size.should == 9
      columns[:timestamp].should == 0
      columns[:first_name].should == 2
      columns[:last_name].should == 1
      columns[:email].should == 3
      columns[:phone].should == 4
      columns[:location].should == 7
      columns[:products].size.should == 8
      columns[:products][@chicken_regular].should == 8
      columns[:products][@import.products[1]].should == 9
      columns[:notes].should == 18
      columns[:total].should == 20
    end

    it "should have multiple location names" do
      @import.location_names.should == ['SF Potrero', 'Farm']
    end

    it "should have multiple pickups" do
      @import.pickups.size.should == 2
      @import.pickups[0].name.should == 'SF Potrero'
      @import.pickups[1].name.should == 'Farm'
    end

    it "should take pickup date from file name" do
      @import.pickups.first.date.should == Date.parse("2010-01-13")
    end

    it "should find existing products by header name" do
      @import.farm.should == @farm
      @import.products[0].should == @chicken_regular
      @import.products[0].new_record?.should == false
    end

    it "should create new products by header name" do
      @import.products[1].name.should == 'Chicken, LARGE'
      @import.products[1].description.should == '$6/lb., 4.5-5.5 lbs'
      @import.products[1].farm.should == @farm
      @import.products[1].new_record?.should == false
    end

    it "should create a stock item for each product" do
      @import.pickups[0].stock_items.size.should == 8
      @import.pickups[0].stock_items[0].product.should == @chicken_regular
    end
  end

  context "Saving the import" do
    it "should create everything" do
      PickupImport.new("#{RAILS_ROOT}/db/import/SFF CSA 1-13-10 TEST.csv").import!

      Pickup.count.should == 2
      StockItem.count.should == 16
      Product.count.should == 8
      Member.count.should == 2
      Order.count.should == 4
    end
  end
end
