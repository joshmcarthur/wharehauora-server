FactoryGirl.define do
  factory :mqtt_user do
    username { Faker::Internet.email }
    password { Faker::Internet.password }
    user
  end
end
