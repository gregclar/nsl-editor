require 'rails_helper'

RSpec.describe Products::ProductTabService do
  let(:config) { Products::ProductTabConfig.new }
  let(:product_no_flags) { instance_double(Product, is_name_index: false, has_default_reference: false) }
  let(:product_with_name_index) { instance_double(Product, is_name_index: true, has_default_reference: false) }
  let(:product_with_default_reference) { instance_double(Product, is_name_index: false, has_default_reference: true) }
  let(:product_with_multiple_flags) { instance_double(Product, is_name_index: true, has_default_reference: true) }

  describe ".call" do
    it "returns a service instance" do
      service = described_class.call(product_no_flags)
      expect(service).to be_a(described_class)
    end
  end

  describe "#execute" do
    context "when product has is_name_index flag true" do
      it "detects active flags" do
        service = described_class.call(product_with_name_index)
        expect(service.active_flags).to include("is_name_index")
        expect(service.active_flags).not_to include("has_default_reference")
      end

      it "enables author and reference models" do
        service = described_class.call(product_with_name_index)
        expect(service.enabled_models).to match_array(["author", "reference"])
      end

      it "returns flag-specific tabs for author model" do
        service = described_class.call(product_with_name_index)
        expect(service.available_tabs_for(:author)).to eq(["new", "details", "edit", "comments"])
      end

      it "returns flag-specific tabs for reference model" do
        service = described_class.call(product_with_name_index)
        expect(service.available_tabs_for(:reference)).to eq(["new", "details", "edit", "comments"])
      end

      it "returns empty tabs for non-enabled name model" do
        service = described_class.call(product_with_name_index)
        expect(service.available_tabs_for(:name)).to eq([])
      end

      it "returns empty tabs for non-enabled instance model" do
        service = described_class.call(product_with_name_index)
        expect(service.available_tabs_for(:instance)).to eq([])
      end
    end

    context "when product has has_default_reference flag true" do
      it "detects active flags" do
        service = described_class.call(product_with_default_reference)
        expect(service.active_flags).to include("has_default_reference")
        expect(service.active_flags).not_to include("is_name_index")
      end

      it "enables only reference model" do
        service = described_class.call(product_with_default_reference)
        expect(service.enabled_models).to eq(["reference"])
      end

      it "returns flag-specific tabs for reference model" do
        service = described_class.call(product_with_default_reference)
        expect(service.available_tabs_for(:reference)).to eq(["new", "details", "edit"])
      end

      it "returns empty tabs for non-enabled models" do
        service = described_class.call(product_with_default_reference)
        expect(service.available_tabs_for(:author)).to eq([])
        expect(service.available_tabs_for(:name)).to eq([])
        expect(service.available_tabs_for(:instance)).to eq([])
      end
    end

    context "when product has no flags set" do
      it "has no active flags" do
        service = described_class.call(product_no_flags)
        expect(service.active_flags).to be_empty
      end

      it "has no enabled models" do
        service = described_class.call(product_no_flags)
        expect(service.enabled_models).to be_empty
      end

      it "returns empty array for any model" do
        service = described_class.call(product_no_flags)
        expect(service.available_tabs_for(:author)).to eq([])
        expect(service.available_tabs_for(:reference)).to eq([])
        expect(service.available_tabs_for(:name)).to eq([])
        expect(service.available_tabs_for(:instance)).to eq([])
      end
    end

    context "when product has multiple flags set" do
      it "detects multiple active flags" do
        service = described_class.call(product_with_multiple_flags)
        expect(service.active_flags).to match_array(["is_name_index", "has_default_reference"])
      end

      it "combines enabled models without duplicates" do
        service = described_class.call(product_with_multiple_flags)
        expect(service.enabled_models).to match_array(["author", "reference"])
      end

      it "combines tabs from multiple flags for author" do
        service = described_class.call(product_with_multiple_flags)
        expect(service.available_tabs_for(:author)).to eq(["new", "details", "edit", "comments"])
      end

      it "combines tabs from multiple flags for reference" do
        service = described_class.call(product_with_multiple_flags)
        expect(service.available_tabs_for(:reference)).to eq(["new", "details", "edit", "comments"])
      end
    end
  end

  describe '#all_available_tabs' do
    context 'with is_name_index flag' do
      it 'returns hash of all enabled model tabs based on flags' do
        service = described_class.call(product_with_name_index)
        expected_result = {
          "author" => ["new", "details", "edit", "comments"],
          "reference" => ["new", "details", "edit", "comments"]
        }
        expect(service.all_available_tabs).to eq(expected_result)
      end
    end

    context "with has_default_reference flag" do
      it "returns hash of enabled model tabs for default reference" do
        service = described_class.call(product_with_default_reference)
        expected_result = {
          "reference" => ["new", "details", "edit"]
        }
        expect(service.all_available_tabs).to eq(expected_result)
      end
    end

    context "with multiple flags" do
      it "returns combined tabs for all enabled models" do
        service = described_class.call(product_with_multiple_flags)
        expected_result = {
          "author" => ["new", "details", "edit", "comments"],
          "reference" => ["new", "details", "edit", "comments"]
        }
        expect(service.all_available_tabs).to eq(expected_result)
      end
    end

    context "with no flags" do
      it "returns empty hash" do
        service = described_class.call(product_no_flags)
        expect(service.all_available_tabs).to eq({})
      end
    end
  end

  describe '#show_product_name_for_model?' do
    context "when product has is_name_index flag true" do
      it "returns false for all models" do
        service = described_class.call(product_with_name_index)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be false
        expect(service.show_product_name_for_model?(:instance)).to be false
      end
    end

    context "when product has has_default_reference flag true" do
      it "returns true for all models" do
        service = described_class.call(product_with_default_reference)
        expect(service.show_product_name_for_model?(:author)).to be true
        expect(service.show_product_name_for_model?(:reference)).to be true
        expect(service.show_product_name_for_model?(:name)).to be true
        expect(service.show_product_name_for_model?(:instance)).to be true
      end
    end

    context "when product has no flags set" do
      it "returns true for all models by default" do
        service = described_class.call(product_no_flags)
        expect(service.show_product_name_for_model?(:author)).to be true
        expect(service.show_product_name_for_model?(:reference)).to be true
        expect(service.show_product_name_for_model?(:name)).to be true
        expect(service.show_product_name_for_model?(:instance)).to be true
      end
    end

    context "when product has multiple flags set" do
      it "returns false when is_name_index is present (takes precedence)" do
        service = described_class.call(product_with_multiple_flags)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
      end
    end
  end

  describe "edge cases" do
    context "with product that does not respond to flag methods" do
      let(:product_without_flags) do
        build(:product).tap do |product|
          allow(product).to receive(:respond_to?) do |method|
            ![:is_name_index, :has_default_reference].include?(method)
          end
        end
      end

      it "handles gracefully when product does not respond to flag methods" do
        service = described_class.call(product_without_flags)
        expect(service.active_flags).to be_empty
        expect(service.enabled_models).to be_empty
        expect(service.all_available_tabs).to eq({})
      end
    end

    context "with nil product" do
      it "handles nil product gracefully" do
        service = described_class.call(nil)
        expect(service.active_flags).to be_empty
        expect(service.enabled_models).to be_empty
        expect(service.all_available_tabs).to eq({})
      end
    end

    context "with product that has flag methods returning nil" do
      let(:product_with_nil_flags) do
        build(:product).tap do |product|
          allow(product).to receive(:is_name_index).and_return(nil)
          product.define_singleton_method(:has_default_reference) { nil }
        end
      end

      it "treats nil flag values as false" do
        service = described_class.call(product_with_nil_flags)
        expect(service.active_flags).to be_empty
        expect(service.enabled_models).to be_empty
      end
    end

    context "with product that raises exceptions on flag access" do
      let(:product_with_errors) do
        build(:product).tap do |product|
          allow(product).to receive(:is_name_index).and_raise(StandardError, 'Database error')
          product.define_singleton_method(:has_default_reference) { false }
        end
      end

      it "handles exceptions during flag detection" do
        expect { described_class.call(product_with_errors) }.to raise_error(StandardError, 'Database error')
      end
    end

    context "when configuration files are missing or corrupted" do
      before do
        allow(File).to receive(:read).and_raise(Errno::ENOENT, "No such file")
      end

      it "does not raise an error" do
        expect { described_class.call(product_no_flags) }.not_to raise_error(Errno::ENOENT)
      end
    end

    context 'with very large number of flags' do
      let(:product_with_many_flags) do
        build(:product).tap do |product|
          # Simulate product with many different flags
          100.times do |i|
            flag_name = "flag_#{i}"
            product.define_singleton_method(flag_name.to_sym) { i.even? }
          end

          product.define_singleton_method(:has_default_reference) { false }
        end
      end

      it 'handles products with many flags efficiently' do
        service = described_class.call(product_with_many_flags)
        expect(service.active_flags).to be_an(Array)
        expect(service.enabled_models).to be_an(Array)
      end
    end
  end
end
