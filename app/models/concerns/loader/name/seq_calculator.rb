module Loader::Name::SeqCalculator
  extend ActiveSupport::Concern

  included do
    def self.calc_seq(params)

      within_genus = self.seek_within_genus(params)
      Rails.logger.debug("within_genus: #{within_genus}")
      return within_genus if within_genus

      within_family = self.seek_within_family(params)
      Rails.logger.debug("within_family: #{within_family}")
      return within_family if within_family

      return 0
    end

    def self.seek_within_family(params)
      Loader::Batch.find(params["loader_batch_id"])
        .loader_names
        .where(simple_name: params["family"])
        .where(rank: 'family')
        .first
        .seq + 1
    rescue => e
      Rails.logger.error("Error in seek_within_family: #{e.to_s}")
      false
    end

    def self.seek_within_genus(params)
      Rails.logger.debug("seek_within_genus")
      first_word = params["simple_name"].sub(/ .*/,'')
      first_wild_s = "#{first_word}%"
      Loader::Batch.find(params["loader_batch_id"])
        .loader_names
        .where("simple_name like '#{first_wild_s}'")
        .where("record_type in ('accepted','excluded')")
        .order("id")
        .first
        .seq - 1
    rescue => e
      Rails.logger.error("Error in seek_within_species: #{e.to_s}")
      Rails.logger.debug("Nothing found in that genus")
      false
    end

  end
end

