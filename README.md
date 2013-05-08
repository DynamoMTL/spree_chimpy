Spree/MailChimp Integration
============

Makes it easy to integrate your [Spree](http://spreecommerce.com) app with [MailChimp](www.mailchimp.com)

- list subscription and unscubribing
- define and sync merge variables
- order submitition
- campaign tracking
- delayed job integration

Installing
-----------

Add spree_hominid to your Gemfile:

```ruby
gem "spree_hominid"
```

Alternatively you can use the git repo directly:

```ruby
gem "spree_hominid", github: "DynamoMTL/spree-hominid"
```

Then, run bundler

    $ bundle


Configuring
----------

Add an initializer that will define the configuration. Only the API key is a required

```ruby
# config/initializers/spree_hominid.rb
Spree::Hominid.config do |config|
  # your API key provided by MailChimp
  config.preferred_key = 'your-api-key'
end
```

If you'd like you can add additional options:

```ruby
# config/initializers/spree_hominid.rb
Spree::Hominid.config do |config|
  # your API key as provided by MailChimp
  config.preferred_key = 'your-api-key'

  # name of your list, defaults to "Members"
  config.preferred_list_name = 'peeps'

  # id of your store. max 10 letters. defaults to "spree"
  config.preferred_store_id = 'acme'

  # define a list of merge vars:
  # - key: a unique name that mail chimp uses. 10 letters max
  # - value: the name of any method on the user class.
  # default is {'EMAIL' => :email}
  config.preferred_merge_vars = {
    'EMAIL' => :email,
    'HAIRCOLOR' => :hair_color
  }
end
```

For deployment on Heroku, you can configure the API username/password with environment variables:

```ruby
# config/initializers/spree_hominid.rb
Spree::Hominid.config do |config|
  config.preferred_key = ENV['MAILCHIMP_API_KEY']
end
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2013 [name of extension creator], released under the New BSD License
