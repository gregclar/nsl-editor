FactoryBot.define do
  factory :user_product_role, class: "User::ProductRole" do
    created_by { "fred" }
    updated_by { "fred" }

    association :product
    association :role_type, factory: :role_type
    association :user
  end
end
