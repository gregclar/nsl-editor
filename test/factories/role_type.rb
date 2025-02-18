FactoryBot.define do
  factory :role_type, class: "Product::RoleType" do
    description { "Please describe this product role type" }
    name { "Role Type" }
    created_by { "fred" }
    updated_by { "fred" }
  end
end
