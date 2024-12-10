require 'rails_helper'

RSpec.describe SignIn, type: :model do

  let(:params) { {username: "username", password: "password"} }

  subject {described_class.new(params) }

  describe "#product_in_context" do
    context "for foa context group" do
      it "returns FOA" do
        allow_any_instance_of(SignIn).to receive(:groups).and_return(['foa-context-group'])
        expect(subject.product_in_context).to eq "FOA"
      end
    end

    context "for non foa context group" do
      it "defaults to APNI" do
        allow_any_instance_of(SignIn).to receive(:groups).and_return(['test'])
        expect(subject.product_in_context).to eq "APNI"
      end
    end
  end
end
