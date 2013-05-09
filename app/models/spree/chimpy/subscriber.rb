class Spree::Chimpy::Subscriber < ActiveRecord::Base
  self.table_name = "spree_chimpy_subscribers"

  attr_accessible :email, :subscribed
  validates :email, presence: true
end
