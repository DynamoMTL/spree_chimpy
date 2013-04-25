class SpreeHominid::OrderSource < ActiveRecord::Base
  belongs_to :order, class_name: 'Spree::Order'

  attr_accessible :campaign_id, :email_id
end
