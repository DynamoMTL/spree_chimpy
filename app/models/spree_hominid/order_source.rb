class SpreeHominid::OrderSource < ActiveRecord::Base
  self.table_name = :spree_hominid_order_sources
  belongs_to :order, class_name: 'Spree::Order'

  attr_accessible :campaign_id, :email_id
end
