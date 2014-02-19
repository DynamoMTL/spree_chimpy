class Spree::Chimpy::Action < ActiveRecord::Base
  self.table_name = "spree_chimpy_actions"
  
  validates :email,
  presence: { :message => "Please specify an email" },
  length:   { :maximum => 100 },
  format:   { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  
  validates_uniqueness_of :email, 
  scope:  :action,
  if:     Proc.new {|mc| [:subscribe, :unsubscribe, :referrer].include?(mc.action.to_s.to_sym)  }
  
  class << self
    def customer_has_subscribed?(email)
      where(email: email).any?
    end
  end

end
