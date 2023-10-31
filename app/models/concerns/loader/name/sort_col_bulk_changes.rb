module Loader::Name::SortColBulkChanges
  extend ActiveSupport::Concern

  class_methods do
    def count_all
      puts self.all.size
    end

    # Note: this will reset all loader_name sorting for the batch
    def set_sort_col(batch, record_type)
      n = 0 
      batch.loader_names.where(record_type: record_type).each do |rec|
        puts "#{rec.simple_name} - #{rec.sort_col}"
        rec.sort_col = nil
        rec.set_sort_col
        rec.save!
        n += 1
        puts "#{rec.simple_name} - #{rec.sort_col}"
      end
      puts n
    end

    # Order is important because synonyms and misapplieds build sort_col on
    # their parent's sort_col value
    # ##############################################################
    # WARNING: this will reset all loader_name sorting for the batch
    # ##############################################################
    def set_sort_col_for_all_record_types(batch)
      set_sort_col(batch,'heading')
      set_sort_col(batch,'accepted')
      set_sort_col(batch,'excluded')
      set_sort_col(batch,'synonym')
      set_sort_col(batch,'misapplied')
      set_sort_col(batch,'in-batch-note')
    end

  end # class_methods

end
