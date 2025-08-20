require 'rails_helper'

RSpec.describe Products::ProductTabConfig do
  let(:config) { described_class.new }

  describe "#tabs_for" do
    context "with active flags" do

      context "for author" do
        it "returns tabs for is_name_index flag for author" do
          tabs = config.tabs_for(:author, ["is_name_index"])
          expect(tabs).to eq(["new", "details", "edit", "comments"])
        end

        it "returns tabs for has_default_reference flag for author" do
          tabs = config.tabs_for(:author, ["has_default_reference"])
          expect(tabs).to eq(["details"])
        end

        it "combines tabs from multiple flags for author" do
          tabs = config.tabs_for(:author, ["is_name_index", "has_default_reference"])
          expect(tabs).to match_array(["new", "details", "edit", "comments"])
        end
      end

      context "for reference" do
        it "returns tabs for is_name_index flag for reference" do
          tabs = config.tabs_for(:reference, ["is_name_index"])
          expect(tabs).to eq(["new", "details", "edit_1", "edit_2", "edit_3", "comments", "new_instance", "copy"])
        end

        it "returns tabs for has_default_reference flag for reference" do
          tabs = config.tabs_for(:reference, ["has_default_reference"])
          expect(tabs).to eq(["details"])
        end

        it "returns unique tabs when flags overlap" do
          tabs = config.tabs_for(:reference, ["is_name_index", "has_default_reference"])
          expect(tabs.uniq).to eq(tabs)
        end

        it "combines tabs from multiple flags for reference" do
          tabs = config.tabs_for(:reference, ["is_name_index", "has_default_reference"])
          expect(tabs).to match_array(["comments", "copy", "details", "edit_1", "edit_2", "edit_3", "new", "new_instance"])
        end
      end

      context "for name" do
        it "returns tabs for is_name_index flag for name" do
          tabs = config.tabs_for(:name, ["is_name_index"])
          expect(tabs).to eq(["new", "details", "edit", "new_instance", "copy", "more", "more_comment", "more_tag"])
        end

        it "returns tabs for is_name_index flag for name" do
          tabs = config.tabs_for(:name, ["is_name_index"])
          expect(tabs).to eq(["new", "details", "edit", "new_instance", "copy", "more", "more_comment", "more_tag"])
        end
      end

      context "for instance" do
        it "returns tabs for is_name_index flag for instance" do
          tabs = config.tabs_for(:instance, ["is_name_index"])
          expect(tabs).to eq(["details", "edit", "syn", "unpub", "notes", "adnot", "copy", "loader"])
        end

        it "returns tabs for has_default_reference flag for instance" do
          tabs = config.tabs_for(:instance, ["has_default_reference"])
          expect(tabs).to eq(["details", "edit", "syn", "unpub", "copy", "loader"])
        end
      end
    end

    context "with no active flags" do
      it "returns default tabs for author" do
        tabs = config.tabs_for(:author, [])
        expect(tabs).to eq(["details"])
      end

      it "returns default tabs for reference" do
        tabs = config.tabs_for(:reference, [])
        expect(tabs).to eq(["details"])
      end

      it "returns default tabs for name" do
        tabs = config.tabs_for(:name, [])
        expect(tabs).to eq(["details"])
      end

      it "returns default tabs for instance" do
        tabs = config.tabs_for(:instance, [])
        expect(tabs).to eq(["details"])
      end
    end

    context "with unknown model" do
      it "returns empty array for unknown model" do
        tabs = config.tabs_for(:unknown, ["is_name_index"])
        expect(tabs).to eq([])
      end
    end

    context "with unknown flags" do
      it "returns default tabs when flag is not configured" do
        tabs = config.tabs_for(:author, ["unknown_flag"])
        expect(tabs).to eq(["details"])
      end

      it "ignores unknown flags when combined with known flags" do
        tabs = config.tabs_for(:author, ["is_name_index", "unknown_flag"])
        expect(tabs).to eq(["new", "details", "edit", "comments"])
      end
    end

    context "edge cases" do
      it "handles string model names" do
        tabs = config.tabs_for("author", ["is_name_index"])
        expect(tabs).to eq(["new", "details", "edit", "comments"])
      end

      it "handles nil flags gracefully" do
        expect { config.tabs_for(:author, nil) }.not_to raise_error
      end
    end
  end

  describe "#enabled_models_for_flags" do
    it "returns enabled models for is_name_index flag" do
      models = config.enabled_models_for_flags(["is_name_index"])
      expect(models).to match_array(["author", "instance", "name", "profile", "reference"])
    end

    it "returns enabled models for has_default_reference flag" do
      models = config.enabled_models_for_flags(["has_default_reference"])
      expect(models).to eq(["author", "reference", "name", "instance", "profile"])
    end

    it "combines models from multiple flags without duplicates" do
      models = config.enabled_models_for_flags(["is_name_index", "has_default_reference"])
      expect(models).to match_array(["author", "instance", "name", "profile", "reference"])
      expect(models.uniq).to eq(models)
    end

    it "returns empty array for no flags" do
      models = config.enabled_models_for_flags([])
      expect(models).to eq([])
    end

    it "returns empty array for unknown flags" do
      models = config.enabled_models_for_flags(["unknown_flag"])
      expect(models).to eq([])
    end

    it "handles nil flags gracefully" do
      expect { config.enabled_models_for_flags(nil) }.not_to raise_error
    end
  end

  describe '#show_product_name_for?' do
    context "when is_name_index flag is active" do
      it 'returns false for author model' do
        result = config.show_product_name_for?(:author, ["is_name_index"])
        expect(result).to be false
      end

      it "returns false for reference model" do
        result = config.show_product_name_for?(:reference, ["is_name_index"])
        expect(result).to be false
      end

      it "returns false for name model" do
        result = config.show_product_name_for?(:name, ["is_name_index"])
        expect(result).to be false
      end

      it "returns false for instance model" do
        result = config.show_product_name_for?(:instance, ["is_name_index"])
        expect(result).to be false
      end
    end

    context "when has_default_reference flag is active" do
      it "returns false for author model" do
        result = config.show_product_name_for?(:author, ["has_default_reference"])
        expect(result).to be false
      end

      it "returns true for reference model" do
        result = config.show_product_name_for?(:reference, ["has_default_reference"])
        expect(result).to be true
      end
    end

    context "when multiple flags are active" do
      it "handles precedence correctly" do
        result = config.show_product_name_for?(:author, ["is_name_index", "has_default_reference"])
        expect(result).to be false
      end
    end

    context "when no flags are active" do
      it "returns false by default for author model" do
        result = config.show_product_name_for?(:author, [])
        expect(result).to be false
      end

      it "returns false by default for reference model" do
        result = config.show_product_name_for?(:reference, [])
        expect(result).to be false
      end
    end

    context "when unknown model is provided" do
      it "returns true for unknown model" do
        result = config.show_product_name_for?(:unknown_model, ["is_name_index"])
        expect(result).to be true
      end
    end
  end

  describe "#flag_config" do
    it 'returns a hash containing flag configurations' do
      config_hash = config.flag_config
      expect(config_hash).to be_a(Hash)
    end

    it "contains expected flag keys" do
      config_hash = config.flag_config
      expect(config_hash.keys).to include("is_name_index", "has_default_reference")
    end

    it "returns consistent results on multiple calls" do
      first_call = config.flag_config
      second_call = config.flag_config
      expect(first_call).to eq(second_call)
    end
  end

  describe "error handling" do
    context "when configuration files are missing" do
      before do
        allow(File).to receive(:read).and_raise(Errno::ENOENT, "No such file")
      end

      it "returns an empty array when accessing tabs_for" do
        expect(config.tabs_for(:author, ["is_name_index"])).to eq([])
      end
    end

    context "when configuration files contain invalid JSON" do
      before do
        allow(File).to receive(:read).and_return("invalid json")
      end

      it "returns an empty hash" do
        result = config.flag_config
        expect(result).to eq({})
      end
    end
  end
end
