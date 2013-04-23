module SpreeHominid
  class Configuration < Spree::Configuration
    preference :key,        :string
    preference :list_name,  :string, default: 'Members'
    preference :merge_vars, :hash,   default: {'EMAIL' => :email}

    def enabled?
      preferred_key.present?
    end

    def interface
      Interface.new(preferred_key) if enabled?
    end
  end
end
