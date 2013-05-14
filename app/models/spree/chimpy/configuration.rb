module Spree::Chimpy
  class Configuration < Spree::Preferences::Configuration
    preference :store_id,   :string,  default: 'spree'
    preference :default,    :boolean, default: false
    preference :key,        :string
    preference :list_name,  :string,  default: 'Members'
    preference :merge_vars, :hash,    default: {'EMAIL' => :email}

    def configured?
      preferred_key.present?
    end

    def list
      Interface::List.new(preferred_key, preferred_list_name) if configured?
    end

    def orders
      Interface::Orders.new(preferred_key) if configured?
    end

    def list_exists?
      list.find_list_id(preferred_list_name)
    end

    def sync_merge_vars
      existing   = list.merge_vars + %w(EMAIL)
      merge_vars = preferred_merge_vars.except(*existing)

      merge_vars.each do |tag, method|
        list.add_merge_var(tag.upcase, method.to_s.humanize.titleize)
      end
    end
  end
end
