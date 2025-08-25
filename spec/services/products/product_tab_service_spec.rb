require 'rails_helper'

RSpec.describe Products::ProductTabService do
  let(:config) { Products::ProductTabConfig.new }
  let(:product_no_flags) { instance_double(Product, id: 1, is_name_index: false, has_default_reference: false, manages_taxonomy: false, manages_profile: false) }
  let(:product_with_name_index) { instance_double(Product, id: 2, is_name_index: true, has_default_reference: false, manages_taxonomy: false, manages_profile: false) }
  let(:product_with_default_reference) { instance_double(Product, id: 3, is_name_index: false, has_default_reference: true, manages_taxonomy: false, manages_profile: false) }
  let(:product_with_multiple_flags) { instance_double(Product, id: 4, is_name_index: true, has_default_reference: true, manages_taxonomy: false, manages_profile: false) }
  let(:product_name_only) { instance_double(Product, id: 5, is_name_index: true, has_default_reference: false, manages_taxonomy: false, manages_profile: false) }
  let(:product_reference_only) { instance_double(Product, id: 6, is_name_index: false, has_default_reference: true, manages_taxonomy: false, manages_profile: false) }
  let(:product_with_manages_taxonomy) { instance_double(Product, id: 7, is_name_index: false, has_default_reference: false, manages_taxonomy: true, manages_profile: false) }
  let(:product_with_manages_profile) { instance_double(Product, id: 8, is_name_index: false, has_default_reference: false, manages_taxonomy: false, manages_profile: true) }
  let(:product_with_all_flags) { instance_double(Product, id: 9, is_name_index: true, has_default_reference: true, manages_taxonomy: true, manages_profile: true) }

  describe ".call" do
    it "returns a service instance with single product" do
      service = described_class.call(product_no_flags)
      expect(service).to be_a(described_class)
    end

    it "returns a service instance with multiple products" do
      service = described_class.call([product_no_flags, product_with_name_index])
      expect(service).to be_a(described_class)
    end

    it "accepts an array of products" do
      service = described_class.call([product_no_flags, product_with_name_index])
      expect(service).to be_a(described_class)
    end
  end

  describe "#execute with single product" do
    context "when product has is_name_index flag true" do
      it "detects active flags" do
        service = described_class.call(product_with_name_index)
        expect(service.active_flags).to include("is_name_index")
        expect(service.active_flags).not_to include("has_default_reference")
      end

      it "enables author and reference models" do
        service = described_class.call(product_with_name_index)
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "returns flag-specific tabs for author model" do
        service = described_class.call(product_with_name_index)
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(author_tab_names).to eq(["new", "details", "edit", "comments"])

        # Check that each tab object has the expected structure
        author_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_name_index)
          expect(tab_obj[:show_product_name]).to eq false
        end
      end

      it "returns flag-specific tabs for reference model" do
        service = described_class.call(product_with_name_index)
        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(reference_tab_names).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])

        # Check that each tab object has the expected structure
        reference_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_name_index)
        end
      end

      it "returns empty tabs for non-enabled name model" do
        service = described_class.call(product_with_name_index)
        expect(service.available_tabs_for(:user)).to eq([])
      end
    end

    context "when product has has_default_reference flag true" do
      it "detects active flags" do
        service = described_class.call(product_with_default_reference)
        expect(service.active_flags).to include("has_default_reference")
        expect(service.active_flags).not_to include("is_name_index")
      end

      it "enables author and reference models" do
        service = described_class.call(product_with_default_reference)
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "returns flag-specific tabs for reference model" do
        service = described_class.call(product_with_default_reference)
        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(reference_tab_names).to eq(["details"])

        # Check structure
        reference_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_default_reference)
        end
      end

      it "returns flag-specific tabs for author model" do
        service = described_class.call(product_with_default_reference)
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(author_tab_names).to eq(["details"])

        # Check structure
        author_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_default_reference)
        end
      end

      it "returns empty tabs for non-enabled models" do
        service = described_class.call(product_with_default_reference)
        expect(service.available_tabs_for(:user)).to eq([])
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
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "combines tabs from multiple flags for author" do
        service = described_class.call(product_with_multiple_flags)
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        expect(author_tab_names).to eq(["new", "details", "edit", "comments"])

        # Check structure for each tab
        author_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_multiple_flags)
        end
      end

      it "combines tabs from multiple flags for reference" do
        service = described_class.call(product_with_multiple_flags)
        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        expect(reference_tab_names).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])

        # Check structure for each tab
        reference_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_multiple_flags)
        end
      end
    end

    context "when product has manages_taxonomy flag true" do
      it "detects active flags" do
        service = described_class.call(product_with_manages_taxonomy)
        expect(service.active_flags).to include("manages_taxonomy")
        expect(service.active_flags).not_to include("is_name_index")
        expect(service.active_flags).not_to include("has_default_reference")
        expect(service.active_flags).not_to include("manages_profile")
      end

      it "enables author and reference models" do
        service = described_class.call(product_with_manages_taxonomy)
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "returns flag-specific tabs for author model" do
        service = described_class.call(product_with_manages_taxonomy)
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(author_tab_names).to eq(["details"])

        # Check structure
        author_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_manages_taxonomy)
        end
      end

      it "returns flag-specific tabs for reference model" do
        service = described_class.call(product_with_manages_taxonomy)
        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(reference_tab_names).to eq(["details"])

        # Check structure
        reference_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_manages_taxonomy)
        end
      end

      it "returns empty tabs for non-enabled models" do
        service = described_class.call(product_with_manages_taxonomy)
        expect(service.available_tabs_for(:idontexist)).to eq([])
      end
    end

    context "when product has manages_profile flag true" do
      it "detects active flags" do
        service = described_class.call(product_with_manages_profile)
        expect(service.active_flags).to include("manages_profile")
        expect(service.active_flags).not_to include("is_name_index")
        expect(service.active_flags).not_to include("has_default_reference")
        expect(service.active_flags).not_to include("manages_taxonomy")
      end

      it "enables author and reference models" do
        service = described_class.call(product_with_manages_profile)
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "returns flag-specific tabs for author model" do
        service = described_class.call(product_with_manages_profile)
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(author_tab_names).to eq(["new", "details"])

        # Check structure
        author_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_manages_profile)
        end
      end

      it "returns flag-specific tabs for reference model" do
        service = described_class.call(product_with_manages_profile)
        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }
        expect(reference_tab_names).to eq(["new", "details", "edit_1", "edit_2", "edit_3"])

        # Check structure
        reference_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_manages_profile)
        end
      end

      it "returns empty tabs for non-enabled models" do
        service = described_class.call(product_with_manages_profile)
        expect(service.available_tabs_for(:idontexist)).to eq([])
      end
    end

    context "when product has all flags set" do
      it "detects all active flags" do
        service = described_class.call(product_with_all_flags)
        expect(service.active_flags).to match_array(["is_name_index", "has_default_reference", "manages_taxonomy", "manages_profile"])
      end

      it "enables author and reference models" do
        service = described_class.call(product_with_all_flags)
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "combines tabs from all flags for author" do
        service = described_class.call(product_with_all_flags)
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        expect(author_tab_names).to eq(["new", "details", "edit", "comments"])

        # Check structure
        author_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_all_flags)
        end
      end

      it "combines tabs from all flags for reference" do
        service = described_class.call(product_with_all_flags)
        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        expect(reference_tab_names).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])

        # Check structure
        reference_tabs.each do |tab_obj|
          expect(tab_obj).to have_key(:tab)
          expect(tab_obj).to have_key(:product)
          expect(tab_obj).to have_key(:show_product_name)
          expect(tab_obj[:product]).to eq(product_with_all_flags)
        end
      end
    end
  end

  describe "#execute with multiple products" do
    context "when products have different flags" do
      let(:products) { [product_name_only, product_reference_only] }
      let(:service) { described_class.call(products) }

      it "detects all active flags from all products" do
        expect(service.active_flags).to contain_exactly("is_name_index", "has_default_reference")
      end

      it "enables models from all active flags" do
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end

      it "returns unified tabs for each model" do
        author_tabs = service.available_tabs_for(:author)
        author_tab_names = author_tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        expect(author_tab_names).to eq(["new", "details", "edit", "comments"])

        reference_tabs = service.available_tabs_for(:reference)
        reference_tab_names = reference_tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        expect(reference_tab_names).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])

        # Check that tabs from both products are included
        author_products = author_tabs.map { |tab_obj| tab_obj[:product] }.uniq
        expect(author_products).to contain_exactly(product_name_only, product_reference_only)

        reference_products = reference_tabs.map { |tab_obj| tab_obj[:product] }.uniq
        expect(reference_products).to contain_exactly(product_name_only, product_reference_only)
      end
    end

    context "when products have overlapping flags" do
      let(:products) { [product_with_name_index, product_with_multiple_flags] }
      let(:service) { described_class.call(products) }

      it "does not duplicate flags" do
        expect(service.active_flags).to contain_exactly("is_name_index", "has_default_reference")
      end

      it "returns unified models without duplicates" do
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end
    end

    context "when some products have no flags" do
      let(:products) { [product_no_flags, product_with_name_index] }
      let(:service) { described_class.call(products) }

      it "includes flags from products that have them" do
        expect(service.active_flags).to contain_exactly("is_name_index")
      end

      it "enables models based on available flags" do
        expect(service.enabled_models).to match_array(["author", "instance", "name", "profile", "reference"])
      end
    end

    context "when all products have no flags" do
      let(:products) do
        [
          product_no_flags,
          instance_double(
            Product,
            id: 7,
            is_name_index: false,
            has_default_reference: false,
            manages_taxonomy: false,
            manages_profile: false
          )
        ]
      end
      let(:service) { described_class.call(products) }

      it "has no active flags" do
        expect(service.active_flags).to be_empty
      end

      it "has no enabled models" do
        expect(service.enabled_models).to be_empty
      end
    end
  end

  describe '#all_available_tabs' do
    context 'with single product having is_name_index flag' do
      it 'returns hash of all enabled model tabs based on flags' do
        service = described_class.call(product_with_name_index)
        result = service.all_available_tabs

        expected_result = {
          "author" => ["new", "details", "edit", "comments"],
          "instance" => ["details", "edit", "syn", "unpub", "notes", "adnot", "copy", "loader"],
          "name" => ["new", "details", "edit", "new_instance", "copy", "more", "more_comment", "more_tag"],
          "profile" => ["details"],
          "reference" => ["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"]
        }

        simplified_result = result.transform_values do |tabs|
          tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        end

        expect(simplified_result).to eq(expected_result)
      end
    end

    context "with single product having has_default_reference flag" do
      it "returns hash of enabled model tabs for default reference" do
        service = described_class.call(product_with_default_reference)
        result = service.all_available_tabs

        expected_result = {
          "author" => ["details"],
          "instance" => ["details", "edit", "syn", "unpub", "copy", "loader"],
          "name" => ["details", "new_instance", "more", "more_tag"],
          "profile" => ["details"],
          "reference" => ["details"]
        }

        simplified_result = result.transform_values do |tabs|
          tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        end

        expect(simplified_result).to eq(expected_result)
      end
    end

    context "with multiple products having different flags" do
      it "returns combined tabs for all enabled models" do
        products = [product_name_only, product_reference_only]
        service = described_class.call(products)
        result = service.all_available_tabs

        expected_result = {
          "author" => ["new", "details", "edit", "comments"],
          "instance" => ["details", "edit", "syn", "unpub", "notes", "adnot", "copy", "loader"],
          "name" => ["new", "details", "edit", "new_instance", "copy", "more", "more_comment", "more_tag"],
          "profile" => ["details"],
          "reference" => ["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"]
        }

        simplified_result = result.transform_values do |tabs|
          tabs.map { |tab_obj| tab_obj[:tab] }.uniq
        end
        expect(simplified_result).to eq(expected_result)
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
    context "when single product has is_name_index flag true" do
      it "returns false for all models" do
        service = described_class.call(product_with_name_index)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be false
        expect(service.show_product_name_for_model?(:instance)).to be false
      end
    end

    context "when single product has has_default_reference flag true" do
      it "returns correct values based on configuration" do
        service = described_class.call(product_with_default_reference)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be true
        expect(service.show_product_name_for_model?(:instance)).to be true
      end
    end

    context "when multiple products have mixed flags" do
      it "returns false when is_name_index is present (takes precedence)" do
        products = [product_with_name_index, product_with_default_reference]
        service = described_class.call(products)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
      end
    end

    context "when product has no flags set" do
      it "returns false for all models by default (based on updated configuration)" do
        service = described_class.call(product_no_flags)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be false
        expect(service.show_product_name_for_model?(:instance)).to be false
      end
    end

    context "when product has multiple flags set" do
      it "returns false when is_name_index is present (takes precedence)" do
        service = described_class.call(product_with_multiple_flags)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
      end
    end

    context "when single product has manages_taxonomy flag true" do
      it "returns false for all models (based on configuration)" do
        service = described_class.call(product_with_manages_taxonomy)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be false
        expect(service.show_product_name_for_model?(:instance)).to be true
      end
    end

    context "when single product has manages_profile flag true" do
      it "returns false for all models (based on configuration)" do
        service = described_class.call(product_with_manages_profile)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be false
        expect(service.show_product_name_for_model?(:instance)).to be true
      end
    end

    context "when product has all flags set" do
      it "returns false for all models (is_name_index takes precedence)" do
        service = described_class.call(product_with_all_flags)
        expect(service.show_product_name_for_model?(:author)).to be false
        expect(service.show_product_name_for_model?(:reference)).to be false
        expect(service.show_product_name_for_model?(:name)).to be false
        expect(service.show_product_name_for_model?(:instance)).to be false
      end
    end
  end

  describe '#tabs_per_product' do
    context 'with single product having is_name_index flag' do
      it 'returns hash mapping product to its models and tabs' do
        service = described_class.call(product_with_name_index)
        result = service.tabs_per_product

        expect(result).to have_key(product_with_name_index)
        expect(result[product_with_name_index]).to have_key("author")
        expect(result[product_with_name_index]).to have_key("reference")
        expect(result[product_with_name_index]["author"]).to eq(["new", "details", "edit", "comments"])
        expect(result[product_with_name_index]["reference"]).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])
      end
    end

    context 'with single product having has_default_reference flag' do
      it 'returns hash mapping product to its models and tabs' do
        service = described_class.call(product_with_default_reference)
        result = service.tabs_per_product

        expect(result).to have_key(product_with_default_reference)
        expect(result[product_with_default_reference]).to have_key("author")
        expect(result[product_with_default_reference]).to have_key("reference")
        expect(result[product_with_default_reference]["author"]).to eq(["details"])
        expect(result[product_with_default_reference]["reference"]).to eq(["details"])
      end
    end

    context 'with multiple products having different flags' do
      it 'returns hash mapping each product to its respective models and tabs' do
        products = [product_name_only, product_reference_only]
        service = described_class.call(products)
        result = service.tabs_per_product

        expect(result).to have_key(product_name_only)
        expect(result).to have_key(product_reference_only)

        # product_name_only has is_name_index flag
        expect(result[product_name_only]["author"]).to eq(["new", "details", "edit", "comments"])
        expect(result[product_name_only]["reference"]).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])

        # product_reference_only has has_default_reference flag
        expect(result[product_reference_only]["author"]).to eq(["details"])
        expect(result[product_reference_only]["reference"]).to eq(["details"])
      end
    end

    context 'with product having no flags' do
      it 'returns empty hash for product' do
        service = described_class.call(product_no_flags)
        result = service.tabs_per_product

        expect(result).to have_key(product_no_flags)
        expect(result[product_no_flags]).to eq({})
      end
    end

    context 'with product having multiple flags' do
      it 'returns combined tabs for the product' do
        service = described_class.call(product_with_multiple_flags)
        result = service.tabs_per_product

        expect(result).to have_key(product_with_multiple_flags)
        expect(result[product_with_multiple_flags]["author"]).to eq(["new", "details", "edit", "comments"])
        expect(result[product_with_multiple_flags]["reference"]).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])
      end
    end
  end

  describe '#tab_options_for' do
    context 'with single product having is_name_index flag' do
      it 'returns tab options for existing tab' do
        service = described_class.call(product_with_name_index)
        result = service.tab_options_for(:author, :new)

        expect(result).to be_a(Hash)
        expect(result[:tab]).to eq("new")
        expect(result[:product]).to eq(product_with_name_index)
        expect(result[:show_product_name]).to eq false
      end

      it 'returns nil for non-existing tab' do
        service = described_class.call(product_with_name_index)
        result = service.tab_options_for(:author, :non_existing)

        expect(result).to be_nil
      end

      it 'returns nil for non-enabled model' do
        service = described_class.call(product_with_name_index)
        result = service.tab_options_for(:some_model, :details)

        expect(result).to be_nil
      end
    end

    context 'with single product having has_default_reference flag' do
      it 'returns tab options for existing reference tab' do
        service = described_class.call(product_with_default_reference)
        result = service.tab_options_for(:reference, :details)

        expect(result).to be_a(Hash)
        expect(result[:tab]).to eq("details")
        expect(result[:product]).to eq(product_with_default_reference)
        expect(result[:show_product_name]).to eq false
      end

      it 'returns tab options for existing author tab' do
        service = described_class.call(product_with_default_reference)
        result = service.tab_options_for(:author, :details)

        expect(result).to be_a(Hash)
        expect(result[:tab]).to eq("details")
        expect(result[:product]).to eq(product_with_default_reference)
        expect(result[:show_product_name]).to eq false
      end

      it 'returns nil for non-existing author tab' do
        service = described_class.call(product_with_default_reference)
        result = service.tab_options_for(:author, :new)

        expect(result).to be_nil
      end
    end

    context 'with multiple products' do
      it 'returns first matching tab options when multiple products have the same tab' do
        products = [product_name_only, product_reference_only]
        service = described_class.call(products)
        result = service.tab_options_for(:reference, :details)

        expect(result).to be_a(Hash)
        expect(result[:tab]).to eq("details")
        expect([product_name_only, product_reference_only]).to include(result[:product])
        expect(result[:show_product_name]).to eq false
      end
    end

    context 'with nil or invalid inputs' do
      it 'returns nil when model is nil' do
        service = described_class.call(product_with_name_index)
        result = service.tab_options_for(nil, :details)

        expect(result).to be_nil
      end

      it 'returns nil when tab is nil' do
        service = described_class.call(product_with_name_index)
        result = service.tab_options_for(:author, nil)

        expect(result).to be_nil
      end

      it 'returns nil when both model and tab are nil' do
        service = described_class.call(product_with_name_index)
        result = service.tab_options_for(nil, nil)

        expect(result).to be_nil
      end
    end

    context 'with product having no flags' do
      it 'returns nil for any model and tab combination' do
        service = described_class.call(product_no_flags)
        result = service.tab_options_for(:author, :details)

        expect(result).to be_nil
      end
    end
  end

  describe "edge cases" do
    context "with product that does not respond to flag methods" do
      let(:product_without_flags) do
        build(:product).tap do |product|
          allow(product).to receive(:respond_to?) do |method|
            ![:is_name_index, :has_default_reference, :manages_taxonomy, :manages_profile].include?(method)
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

    context "with array containing nil products" do
      it "filters out nil products" do
        products = [product_with_name_index, nil, product_with_default_reference, nil]
        service = described_class.call(products)
        expect(service.active_flags).to contain_exactly("is_name_index", "has_default_reference")
      end
    end

    context "with product that has flag methods returning nil" do
      let(:product_with_nil_flags) do
        build(:product).tap do |product|
          allow(product).to receive(:is_name_index).and_return(nil)
          allow(product).to receive(:has_default_reference).and_return(nil)
          allow(product).to receive(:manages_taxonomy).and_return(nil)
          allow(product).to receive(:manages_profile).and_return(nil)
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
          allow(product).to receive(:has_default_reference).and_return(false)
          allow(product).to receive(:manages_taxonomy).and_return(false)
          allow(product).to receive(:manages_profile).and_return(false)
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

    context "edge cases for new methods" do
      describe "#tabs_per_product" do
        it "handles nil product gracefully" do
          service = described_class.call(nil)
          result = service.tabs_per_product
          expect(result).to eq({})
        end

        it "handles empty product array" do
          service = described_class.call([])
          result = service.tabs_per_product
          expect(result).to eq({})
        end

        it "handles array with nil products" do
          products = [product_with_name_index, nil]
          service = described_class.call(products)
          result = service.tabs_per_product

          expect(result).to have_key(product_with_name_index)
          expect(result).not_to have_key(nil)
        end
      end

      describe "#tab_options_for" do
        it "handles nil model gracefully" do
          service = described_class.call(product_with_name_index)
          result = service.tab_options_for(nil, :details)
          expect(result).to be_nil
        end

        it "handles nil tab gracefully" do
          service = described_class.call(product_with_name_index)
          result = service.tab_options_for(:author, nil)
          expect(result).to be_nil
        end

        it "handles both nil parameters" do
          service = described_class.call(product_with_name_index)
          result = service.tab_options_for(nil, nil)
          expect(result).to be_nil
        end

        it "handles invalid model" do
          service = described_class.call(product_with_name_index)
          result = service.tab_options_for(:invalid_model, :details)
          expect(result).to be_nil
        end

        it "handles invalid tab" do
          service = described_class.call(product_with_name_index)
          result = service.tab_options_for(:author, :invalid_tab)
          expect(result).to be_nil
        end

        it "works with string parameters" do
          service = described_class.call(product_with_name_index)
          result = service.tab_options_for("author", "new")
          expect(result).to be_a(Hash)
          expect(result[:tab]).to eq("new")
        end
      end

      describe "#available_tabs_for" do
        it "handles nil model gracefully" do
          service = described_class.call(product_with_name_index)
          result = service.available_tabs_for(nil)
          expect(result).to eq([])
        end

        it "handles invalid model" do
          service = described_class.call(product_with_name_index)
          result = service.available_tabs_for(:invalid_model)
          expect(result).to eq([])
        end

        it "works with string model parameter" do
          service = described_class.call(product_with_name_index)
          result = service.available_tabs_for("author")
          expect(result).to be_an(Array)
          expect(result.length).to be > 0
        end
      end

      describe "#show_product_name_for_model?" do
        it "handles nil model gracefully" do
          service = described_class.call(product_with_name_index)
          result = service.show_product_name_for_model?(nil)
          expect(result).to be false
        end

        it "handles invalid model" do
          service = described_class.call(product_with_name_index)
          result = service.show_product_name_for_model?(:invalid_model)
          expect(result).to eq true
        end

        it "works with string model parameter" do
          service = described_class.call(product_with_name_index)
          result = service.show_product_name_for_model?("author")
          expect(result).to eq false
        end
      end
    end
  end
end
