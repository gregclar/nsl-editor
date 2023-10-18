

class Search::Loader::Name::RewriteResultsShowingComments 

  def initialize(results)
    @results = results
  end

  def results
    debug('START OF RESULTS')
    @results_with_comments = []
    waiting_for_next_accepted = false
    first_accepted_record = true
    @results.each do |rec|
      debug("TOP OF LOOP  rec.id: #{rec.id}; rec[:record_type]: #{rec[:record_type].upcase}")

      if rec[:record_type] == 'accepted' then
        debug(' ---- FOUND an accepted record')
        if first_accepted_record then
          first_accepted_record = false
          @previous_accepted_rec = rec.clone
          waiting_for_next_accepted = true
        else
          unless @previous_accepted_rec.nil?
            concept_note_and_cn_comments(@previous_accepted_rec)
            dist_and_dist_comments(@previous_accepted_rec)
            @previous_accepted_rec = nil
          end
          @previous_accepted_rec = rec.clone
          waiting_for_next_accepted = true
        end
      end
      if rec[:record_type] == 'in-batch-note' ||
         rec[:record_type] == 'heading' ||
         rec[:record_type] == 'excluded'
      then
        unless @previous_accepted_rec.nil?
          concept_note_and_cn_comments(@previous_accepted_rec)
          dist_and_dist_comments(@previous_accepted_rec)
          @previous_accepted_rec = nil
        end
      end
      debug(" ---- Adding rec #{rec.id}")
      @results_with_comments << rec
      comments_query = Loader::Name::Review::Comment::AsArray::ForLoaderName
                        .new(rec, 'accepted')
      comments_query.results.each { |i| @results_with_comments << i }
      comments_query = Loader::Name::Review::Comment::AsArray::ForLoaderName
                        .new(rec, 'synonym')
      comments_query.results.each { |i| @results_with_comments << i }
      comments_query = Loader::Name::Review::Comment::AsArray::ForLoaderName
                        .new(rec, 'misapplied')
      comments_query.results.each { |i| @results_with_comments << i }

    end # loop
    @results_with_comments
  end

  private

  def debug(s)
    #Rails.logger.debug("========= #{s} =====================================")
  end

  def dist_and_dist_comments(rec)
    unless rec['distribution'].blank?
      dist = Hash.new
      dist[:display_as] = 'Loader Name'
      dist[:record_type] = 'distribution'
      dist[:payload] = rec['distribution']
      @results_with_comments << dist
    end
    debug(" ---- ---- Adding distribution comments for #{rec.id}")
    dist_comments = Loader::Name::Review::Comment::AsArray::ForLoaderName
                      .new(rec, 'distribution')
    dist_comments.results.each { |i| @results_with_comments << i }
  end

  def concept_note_and_cn_comments(rec)
    unless rec['comment'].blank?
      h = Hash.new
      h[:display_as] = 'Loader Name'
      h[:record_type] = 'concept-note'
      h[:payload] = rec['comment']
      @results_with_comments << h
    end
    debug(" ---- ---- Adding concept-note comments for #{rec.id}")
    comments_query = Loader::Name::Review::Comment::AsArray::ForLoaderName
                        .new(rec, 'concept-note')
    comments_query.results.each { |i| @results_with_comments << i }
  end
 
end
