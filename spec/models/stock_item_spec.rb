# == Schema Information
#
# Table name: stock_items
#
#  id                      :integer(4)      not null, primary key
#  delivery_id             :integer(4)
#  product_id              :integer(4)
#  max_quantity_per_member :integer(4)
#  quantity_available      :integer(4)
#  substitutions_available :boolean(1)
#  notes                   :text
#  created_at              :datetime
#  updated_at              :datetime
#  hide                    :boolean(1)
#  product_name            :string(255)
#  product_description     :text
#  product_price           :float
#  product_estimated       :boolean(1)
#  product_price_code      :string(255)
#

require 'spec_helper'

describe StockItem do
  before(:each) do
    @product = Factory(:product, :category => "poultry")
    @valid_attributes = {
      :product_id => @product.id,
      :delivery_id => 4
    }
  end

  it "should create a new instance given valid attributes" do
    StockItem.create!(@valid_attributes)
  end

  it "should return sold out status" do
    eggs = Factory(:stock_item, :quantity_available => 2)
    eggs.sold_out?.should == false

    2.times {Factory(:order_item, :stock_item => eggs)}
    eggs.sold_out?.should == true
  end

  it "should have product attributes after save" do
    stock_item = StockItem.create!(@valid_attributes)

    stock_item.product_description.should  == @product.description
    stock_item.product_name.should         == @product.name
    stock_item.product_price.should        == @product.price
    stock_item.product_estimated.should    == @product.estimated
    stock_item.product_price_code.should   == @product.price_code
    stock_item.product_category.should     == @product.category
  end

  it "should return quantity ordered" do
    stock_item = Factory(:stock_item, :quantity_available => 10)
    Factory(:order_item, :stock_item => stock_item, :quantity => 4)

    stock_item.quantity_ordered.should == 4
    stock_item.quantity_remaining.should == 6

  end

  it "should have available_per_member that returns min(limit, avail)" do
    stock_item = Factory(:stock_item, :quantity_available => 5, :max_quantity_per_member => 3)
    stock_item.available_per_member.should == 3
    Factory(:order_item, :stock_item => stock_item, :quantity => 3)
    stock_item.available_per_member.should == 2
    Factory(:order_item, :stock_item => stock_item, :quantity => 2)
    stock_item.available_per_member.should == 0
  end

end
