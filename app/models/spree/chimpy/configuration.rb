module Spree::Chimpy
  class Configuration < Spree::Preferences::Configuration
    preference :store_id,   :string, default: 'spree'
    preference :key,        :string
    preference :list_name,  :string, default: 'Members'
    preference :static_segment_name,   :string, default: "customers"
    preference :merge_vars, :hash,   default: {'EMAIL' => :email}

    def configured?
      preferred_key.present?
    end

    def list
      Interface::List.new(preferred_key, preferred_list_name, preferred_static_segment_name) if configured?
    end

    def orders
      Interface::Orders.new(preferred_key) if configured?
    end

    def list_exists?
      list.find_list_id(preferred_list_name)
    end
    
    def static_segment_exists?
      list.find_static_segment_id(preferred_static_segment_name)
    end
    
    def create_static_segment
      list.create_static_segment_by_name(preferred_static_segment_name)
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
