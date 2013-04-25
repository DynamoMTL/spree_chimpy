module SpreeHominid
  class Configuration < Spree::Preferences::Configuration
    preference :store_id,   :string, default: 'spree'
    preference :key,        :string
    preference :list_name,  :string, default: 'Members'
    preference :merge_vars, :hash,   default: {'EMAIL' => :email}

    def enabled?
      preferred_key.present?
    end

    def interface
      Interface.new(preferred_key, preferred_list_name) if enabled?
    end

    def list_exists?
      interface.find_list_id(preferred_list_name)
    end

    def sync_merge_vars
      existing   = interface.merge_vars + %w(EMAIL)
      merge_vars = preferred_merge_vars.except(*existing)

      merge_vars.each do |tag, method|
        interface.add_merge_var(tag.upcase, method.to_s.humanize.titleize)
      end
    end
  end
end
