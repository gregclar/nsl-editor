# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instance::AsArray::ForName, type: :model do
  let(:name) { create(:name) }
  let(:primary_type) { create(:instance_type, standalone: true, primary_instance: true, relationship: false) }
  let(:secondary_type) { create(:instance_type, standalone: true, primary_instance: false, relationship: false) }

  def create_instance(name:, draft:, author_name:, year:, iso_date:, primary: false)
    author = create(:author, name: author_name)
    reference = create(:reference, author: author, year: year, iso_publication_date: iso_date)
    instance_type = primary ? primary_type : secondary_type
    create(:instance, name: name, reference: reference, instance_type: instance_type, draft: draft)
  end

  describe "sorting draft instances first" do
    let!(:non_draft_old) { create_instance(name: name, draft: false, author_name: "Alpha", year: 1990, iso_date: "1990", primary: true) }
    let!(:non_draft_new) { create_instance(name: name, draft: false, author_name: "Beta", year: 2000, iso_date: "2000") }
    let!(:draft_by_alpha) { create_instance(name: name, draft: true, author_name: "Alpha", year: 2020, iso_date: "2020") }
    let!(:draft_by_zeta) { create_instance(name: name, draft: true, author_name: "Zeta", year: 2021, iso_date: "2021") }

    subject { described_class.new(name) }

    let(:standalone_results) { subject.results.select { |r| r.is_a?(Instance) && r.standalone? } }
    let(:draft_results) { standalone_results.select(&:draft?) }
    let(:non_draft_results) { standalone_results.reject(&:draft?) }

    it "places all draft instances before non-draft instances" do
      last_draft_idx = subject.results.index(draft_results.last)
      first_non_draft_idx = subject.results.index(non_draft_results.first)

      expect(last_draft_idx).to be < first_non_draft_idx
    end

    it "sorts draft instances by author name in descending order" do
      author_names = draft_results.map { |i| i.reference.author.name }

      expect(author_names).to eq(["Zeta", "Alpha"])
    end

    it "sorts non-draft instances by year ascending" do
      years = non_draft_results.map { |i| i.reference.year.to_i }

      expect(years).to eq([1990, 2000])
    end
  end

  describe "when there are no draft instances" do
    let!(:instance_old) { create_instance(name: name, draft: false, author_name: "Alpha", year: 1990, iso_date: "1990", primary: true) }
    let!(:instance_new) { create_instance(name: name, draft: false, author_name: "Beta", year: 2000, iso_date: "2000") }

    subject { described_class.new(name) }

    it "sorts by the original multi-field sort order" do
      standalone_results = subject.results.select { |r| r.is_a?(Instance) && r.standalone? }
      years = standalone_results.map { |i| i.reference.year.to_i }

      expect(years).to eq([1990, 2000])
    end
  end

  describe "when all instances are drafts" do
    let!(:draft_by_alpha) { create_instance(name: name, draft: true, author_name: "Alpha", year: 2020, iso_date: "2020") }
    let!(:draft_by_zeta) { create_instance(name: name, draft: true, author_name: "Zeta", year: 2021, iso_date: "2021") }

    subject { described_class.new(name) }

    it "sorts by author name in descending order" do
      standalone_results = subject.results.select { |r| r.is_a?(Instance) && r.standalone? }
      author_names = standalone_results.map { |i| i.reference.author.name }

      expect(author_names).to eq(["Zeta", "Alpha"])
    end
  end
end
