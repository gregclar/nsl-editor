module Loader::Name::SortKeyBulkChanges
  extend ActiveSupport::Concern

  class_methods do
    def count_all
      puts self.all.size
    end

    # Note: this will reset all loader_name sorting for the batch
    def set_sort_key(batch, record_type)
      n = 0 
      batch.loader_names.where(record_type: record_type).each do |rec|
        puts "#{rec.simple_name} - #{rec.sort_key}"
        rec.sort_key = nil
        rec.set_sort_key
        rec.save!
        n += 1
        puts "#{rec.simple_name} - #{rec.sort_key}"
      end
      puts n
    end

    # Order is important here because synonyms and misapplieds build
    # sort_key using their parent's sort_key value
    # ##############################################################
    # WARNING: this will reset all loader_name sorting for the batch
    # ##############################################################
    def set_sort_key_for_all_record_types(batch)
      set_sort_key(batch,'heading')
      set_sort_key(batch,'accepted')
      set_sort_key(batch,'excluded')
      set_sort_key(batch,'synonym')
      set_sort_key(batch,'misapplied')
      set_sort_key(batch,'in-batch-note')
    end

  end # class_methods

end
