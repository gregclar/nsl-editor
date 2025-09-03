require "rails_helper"

RSpec.describe ProductContext, type: :model do
  it "is valid with valid attributes" do
    product_context = build(:product_context)
    expect(product_context).to be_valid
  end

  it "is not valid without a product" do
    product_context = build(:product_context, product: nil)
    expect(product_context).to_not be_valid
  end
end
