class Spree::Hominid::Subscriber < ActiveRecord::Base
  self.table_name = "spree_hominid_subscribers"
  
  attr_accessible :email, :subscribed
  validates :email, presence: true
end
