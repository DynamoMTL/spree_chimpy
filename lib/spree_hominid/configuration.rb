class SpreeHominid::Configuration < Spree::Configuration
  preference :key,        :string
  preference :list_name,  :string, default: 'Members'
  preference :merge_vars, :hash,   default: {'EMAIL' => :email}
end
