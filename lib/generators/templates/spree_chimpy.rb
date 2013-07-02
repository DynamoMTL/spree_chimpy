Spree::Chimpy.config do |config|
  # your API key as provided by MailChimp
  # config.key = 'your-api-key'

  # name of your list, defaults to "Members"
  # config.list_name = 'peeps'
  
  # allow users to be subscribed by default. Defaults to false
  # if you choose to turn this to true, it's strongly advised to turn on
  # double_opt_in. Abusing this may cause your Mailchimp account to be suspended.
  # config.subscribed_by_default = false

  # change the double-opt-in behavior. Defaults to false
  # config.double_opt_in = false  
    
  # id of your store. max 10 letters. defaults to "spree"
  # config.store_id = 'acme'

  # define a list of merge vars:
  # - key: a unique name that mail chimp uses. 10 letters max
  # - value: the name of any method on the user class.
  # default is {'EMAIL' => :email}
  # config.merge_vars = {
  #   'EMAIL' => :email,
  #   'HAIRCOLOR' => :hair_color
  # }
end
