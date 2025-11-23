# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Instances::NameTreeQueryService do

  describe "#execute" do
    subject(:service) { described_class.new(instance: instance) }

    context "when instance is linked to a single non-read-only tree" do
      let(:instance) { create(:instance) }
      let(:tree) { create(:tree, name: "APC", is_read_only: false) }
      let(:tree_version) { create(:tree_version, tree: tree) }
      let(:tree_element) { create(:tree_element, instance: instance) }

      before do
        tree.update!(current_tree_version_id: tree_version.id)
        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: tree_version.id,
          element_link: "test/#{tree_element.id}",
          taxon_id: tree_element.id)
      end

      it "returns the tree name" do
        result = service.execute
        expect(result).to be_present
        expect(result.first[:name]).to eq("APC")
      end

      it "returns result containing the instance id" do
        result = service.execute
        expect(result.first.id).to eq(instance.id)
      end
    end

    context "when instance is linked to multiple non-read-only trees" do
      let(:instance) { create(:instance) }
      let(:tree_apc) { create(:tree, name: "APC", is_read_only: false) }
      let(:tree_foa) { create(:tree, name: "FOA", is_read_only: false) }
      let(:tree_version_apc) { create(:tree_version, tree: tree_apc) }
      let(:tree_version_foa) { create(:tree_version, tree: tree_foa) }
      let(:tree_element) { create(:tree_element, instance: instance) }

      before do
        tree_apc.update!(current_tree_version_id: tree_version_apc.id)
        tree_foa.update!(current_tree_version_id: tree_version_foa.id)

        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: tree_version_apc.id,
          element_link: "test/apc/#{tree_element.id}",
          taxon_id: tree_element.id)

        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: tree_version_foa.id,
          element_link: "test/foa/#{tree_element.id}",
          taxon_id: tree_element.id)
      end

      it "returns multiple tree results" do
        result = service.execute
        expect(result.length).to eq(2)
      end

      it "returns each tree name separately" do
        result = service.execute
        tree_names = result.map { |r| r[:name] }
        expect(tree_names).to include("APC")
        expect(tree_names).to include("FOA")
      end
    end

    context "when instance has no tree elements" do
      let(:instance) { create(:instance) }

      it "returns empty result" do
        result = service.execute
        expect(result).to be_empty
      end
    end

    context "when instance is linked only to read-only trees" do
      let(:instance) { create(:instance) }
      let(:tree) { create(:tree, name: "ReadOnlyTree", is_read_only: false) }
      let(:tree_version) { create(:tree_version, tree: tree) }
      let(:tree_element) { create(:tree_element, instance: instance) }

      before do
        tree.update!(current_tree_version_id: tree_version.id, is_read_only: true)
        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: tree_version.id,
          element_link: "test/readonly/#{tree_element.id}",
          taxon_id: tree_element.id)
      end

      it "returns empty result" do
        result = service.execute
        expect(result).to be_empty
      end
    end

    context "when instance is linked to both read-only and non-read-only trees" do
      let(:instance) { create(:instance) }
      let(:readonly_tree) { create(:tree, name: "ReadOnlyTree", is_read_only: false) }
      let(:editable_tree) { create(:tree, name: "EditableTree", is_read_only: false) }
      let(:readonly_version) { create(:tree_version, tree: readonly_tree) }
      let(:editable_version) { create(:tree_version, tree: editable_tree) }
      let(:tree_element) { create(:tree_element, instance: instance) }

      before do
        readonly_tree.update!(current_tree_version_id: readonly_version.id, is_read_only: true)
        editable_tree.update!(current_tree_version_id: editable_version.id)

        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: readonly_version.id,
          element_link: "test/readonly/#{tree_element.id}",
          taxon_id: tree_element.id)

        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: editable_version.id,
          element_link: "test/editable/#{tree_element.id}",
          taxon_id: tree_element.id)
      end

      it "returns only non-read-only trees" do
        result = service.execute
        expect(result.length).to eq(1)
        expect(result.first[:name]).to eq("EditableTree")
      end

      it "excludes read-only trees" do
        result = service.execute
        tree_names = result.map { |r| r[:name] }
        expect(tree_names).not_to include("ReadOnlyTree")
      end
    end

    context "when tree version is not the current version" do
      let(:instance) { create(:instance) }
      let(:tree) { create(:tree, name: "APC", is_read_only: false) }
      let(:old_version) { create(:tree_version, tree: tree) }
      let(:current_version) { create(:tree_version, tree: tree) }
      let(:tree_element) { create(:tree_element, instance: instance) }

      before do
        tree.update!(current_tree_version_id: current_version.id)
        create(:tree_version_element,
          tree_element_id: tree_element.id,
          tree_version_id: old_version.id,
          element_link: "test/old/#{tree_element.id}",
          taxon_id: tree_element.id)
      end

      it "returns empty result when instance is only in old version" do
        result = service.execute
        expect(result).to be_empty
      end
    end
  end

  describe ".call" do
    let(:instance) { create(:instance) }

    it "instantiates and executes the service" do
      service = described_class.call(instance: instance)
      expect(service).to be_a(described_class)
      expect(service.name_trees).not_to be_nil
    end
  end
end
