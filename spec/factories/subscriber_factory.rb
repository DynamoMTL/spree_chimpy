FactoryGirl.define do
  factory :subscriber, class: Spree::Chimpy::Subscriber do
    sequence(:email) { |n| "foo#{n}@email.com" }
    subscribed true
  end
end
