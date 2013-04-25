require 'spec_helper'

describe Spree::Hominid::Interface::List do
  let(:interface) { Spree::Hominid::Interface::List.new('1234', 'Members') }
  let(:api)       { mock(:api) }

  before do
    Spree::Hominid::Config.preferred_key = '1234'
    Hominid::API.should_receive(:new).with('1234', api_version: '1.3').and_return(api)
  end

  it "subscribes" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_subscribe).with('a3d3', 'user@example.com', {'SIZE' => '10'}, update_existing: true)
    interface.subscribe("user@example.com", 'SIZE' => '10')
  end

  it "unsubscribes" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_unsubscribe).with('a3d3', 'user@example.com')
    interface.unsubscribe("user@example.com")
  end

  it "find list id" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    interface.find_list_id('Members')
  end

  it "checks if merge var exists" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_merge_vars).with('a3d3').and_return([{'tag' => 'FOO'}, {'tag' => 'BAR'}])
    interface.merge_vars.should == %w(FOO BAR)
  end

  it "adds a merge var" do
    api.should_receive(:find_list_id_by_name).with('Members').and_return('a3d3')
    api.should_receive(:list_merge_var_add).with('a3d3', 'SIZE', 'Your Size')
    interface.add_merge_var('SIZE', 'Your Size')
  end

  it "adds an order" do
    Spree::Config.preferred_site_name = "Super Store"
    Spree::Hominid::Config.preferred_store_id = "super-store"

    variant  = OpenStruct.new(id: 10, sku: 'WDG-22', name: 'Widget', cost_price: 10)
    line     = OpenStruct.new(variant: variant, quantity: 2)
    order    = OpenStruct.new(number: 123, email: 'user@example.com', total: 100, completed_at: Date.new(2015, 1, 1), tax_total: 0.50, ship_total: 1.50, line_items: [line])
    expected = {
      id:         123,
      email_id:   nil,
      email:      'user@example.com',
      total:      100,
      order_date: Date.new(2015,1,1),
      shipping:   1.50,
      tax:        0.50,
      store_name: 'Super Store',
      store_id:   'super-store',
      items:      [{
                     product_id:   10,
                     sku:          "WDG-22",
                     product_name: "Widget",
                     cost:         10,
                     qty:          2
                  }]
    }

    api.should_receive(:ecomm_order_add).with(expected).and_return(true)

    interface.add_order(order).should be_true
  end

  it "removes an order" do
    Spree::Hominid::Config.preferred_store_id = "super-store"
    order = OpenStruct.new(number: 123)
    api.should_receive(:ecomm_order_del).with('super-store',123).and_return(true)

    interface.remove_order(order).should be_true
  end
end
