FactoryGirl.define do
  factory :role do
    name 'roleyrole'
    friendly_name 'Friend'
  end
  trait :janitor do
    name { 'janitor' }
    friendly_name { 'Janitor' }
  end
end
