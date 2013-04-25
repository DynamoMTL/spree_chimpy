Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Hominid::OrderSource'
end
