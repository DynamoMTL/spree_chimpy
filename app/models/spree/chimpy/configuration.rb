module Spree::Chimpy
  class Configuration < Spree::Preferences::Configuration
    preference :store_id,              :string,  default: 'spree'
    preference :subscribed_by_default, :boolean, default: false
    preference :key,                   :string
    preference :list_name,             :string,  default: 'Members'
    preference :customer_segment_name, :string,  default: 'Customers'
    preference :merge_vars,            :hash,    default: {'EMAIL' => :email}
    preference :double_opt_in,         :boolean, default: false
  end
end
