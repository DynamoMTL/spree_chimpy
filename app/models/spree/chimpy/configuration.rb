module Spree::Chimpy
  class Configuration < Spree::Preferences::Configuration
    preference :store_id,                 :string,  default: 'spree'
    preference :subscribed_by_default,    :boolean, default: false
    preference :key,                      :string
    preference :list_name,                :string,  default: 'Members'
    preference :customer_segment_name,    :string,  default: 'Customers'
    preference :merge_vars,               :hash,    default: { 'EMAIL' => :email }
    preference :api_options,              :hash,    default: { timeout: 60 }
    preference :double_opt_in,            :boolean, default: false
    preference :to_usd_rates,             :hash,    default: {'USD' => 1, 'GBP' => 1.67, 'EUR' => 1.37}
    preference :to_gbp_rates,             :hash,    default: {'GBP' => 1, 'USD' => 0.60, 'EUR' => 0.82}
  end
end
