class Spree::Hominid::Subscriber
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  extend ActiveModel::Naming

  attr_accessor :email

  validates :email, presence: true

  def initialize(attributes = {})
    Spree::Hominid::Config.preferred_merge_vars.values.each do |value|
      self.class.send(:attr_accessor, value)
    end
    self.class.send(:attr_accessible, Spree::Hominid::Config.preferred_merge_vars.values)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def subscribed
    true
  end

  def subscribed_changed?
    true
  end

  def changes
    { 'subscribed' => [false, true] }
  end

  def persisted?
    false
  end
end
