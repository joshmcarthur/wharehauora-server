FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  trait :janitor_user do
    roles { [create(:role, :janitor)] }
  end
end
