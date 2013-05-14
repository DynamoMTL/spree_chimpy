Spree/MailChimp Integration
============

Makes it easy to integrate your [Spree](http://spreecommerce.com) app with [MailChimp](http://www.mailchimp.com)

- list subscription and unsubscribing
- define and sync merge variables
- sync order information with MailChimp's [eCommerce360](http://kb.mailchimp.com/article/what-is-ecommerce360-and-how-does-it-work-with-mailchimp/)
- campaign tracking

Installing
-----------

Add spree_hominid to your Gemfile:

```ruby
gem "spree_chimpy"
```

Alternatively you can use the git repo directly:

```ruby
gem "spree_chimpy", github: "DynamoMTL/spree_chimpy"
```

Run bundler

    $ bundle

Install migrations & initializer file

	bundle exec rails g spree_chimpy:install

MailChimp Setup
---------------

If you dont already have an account, you can [create one here](https://login.mailchimp.com/signup/), its free
Make sure you create a list. The list name setting defaults to "Members", but you configure any name you want via the `#preferred_list_name` setting

Spree Setup
-----------

Add an initializer that will define the configuration. Only the API key is a required

```ruby
# config/initializers/spree_chimpy.rb
Spree::Chimpy.config do |config|
  # your API key provided by MailChimp
  config.preferred_key = 'your-api-key'
end
```

If you'd like you can add additional options:

```ruby
# config/initializers/spree_chimpy.rb
Spree::Chimpy.config do |config|
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
# config/initializers/spree_chimpy.rb
Spree::Chimpy.config do |config|
  config.preferred_key = ENV['MAILCHIMP_API_KEY']
end
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app

To run tests:

    $ bundle exec rspec spec

To run tests with guard (preferred):

    $ bundle exec guard

Copyright (c) 2013 Dynamo, released under the New BSD License
