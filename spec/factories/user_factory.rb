FactoryGirl.define do
  factory :user_with_subscribe_option, parent: :user do
    subscribed false
  end
end
