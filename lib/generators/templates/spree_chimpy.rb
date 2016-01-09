Spree::Chimpy.config do |config|
  # your API key as provided by MailChimp
  # config.key = 'your-api-key'

  # extra api options for the Mailchimp gem
  # config.api_options = { throws_exceptions: false, timeout: 3600 }

  # list_id of the list you want to use.
  # These ID's can be found by visiting your list in the Mailchimp admin,
  # clicking on the settings tab, then the list names and defaults option.
  # config.list_id = 'some_list_id'

  # Allow users to be subscribed by default. Defaults to false
  # If you enable this option, it's strongly advised that your enable
  # double_opt_in as well. Abusing this may cause Mailchimp to suspend your account.
  # config.subscribed_by_default = false

  # When double-opt is enabled, the user will receive an email
  # asking to confirm their subscription. Defaults to false
  # config.double_opt_in = false

  # Send a welcome email after subscribing to a list.
  # It is recommended to send on wieh double_opt_in is false.
  # config.send_welcome_email = true

  # id of your store. max 10 letters. defaults to "spree"
  # config.store_id = 'acme'

  # define a list of merge vars:
  # - key: a unique name that mail chimp uses. 10 letters max
  # - value: the name of any method on the user class.
  # make sure to avoid any of these reserved field names:
  # http://kb.mailchimp.com/article/i-got-a-message-saying-that-my-list-field-name-is-reserved-and-cant-be-used
  # default is {'EMAIL' => :email}
  # config.merge_vars = {
  #   'EMAIL' => :email,
  #   'HAIRCOLOR' => :hair_color
  # }
end
