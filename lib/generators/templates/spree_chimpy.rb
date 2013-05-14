Spree::Chimpy.config do |config|
  # your API key as provided by MailChimp
  # config.preferred_key = 'your-api-key'

  # name of your list, defaults to "Members"
  # config.preferred_list_name = 'peeps'

  # id of your store. max 10 letters. defaults to "spree"
  # config.preferred_store_id = 'acme'

  # define a list of merge vars:
  # - key: a unique name that mail chimp uses. 10 letters max
  # - value: the name of any method on the user class.
  # default is {'EMAIL' => :email}
  # config.preferred_merge_vars = {
  #   'EMAIL' => :email,
  #   'HAIRCOLOR' => :hair_color
  # }
end