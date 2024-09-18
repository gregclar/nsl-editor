
// Define the lock variable globally
window.typeaheadLock = false; 

function setUpInstanceReferenceFoa() {
  alert("----------------- setUpInstanceReferenceFoa!! ---------------------");

  $('.instance-reference-typeahead').each(function () {
    // Check if typeahead is already initializing or initialized
    if ($(this).data('typeahead-initialized')) {
      console.log('Typeahead is already initialized, skipping...');
      return;  // Skip further initialization
    }

    // Initialize typeahead with Bloodhound suggestion engine
    $(this).typeahead(
      { highlight: true, minLength: 1 },  // Ensure minLength is set
      {
        name: 'instance-reference',
        displayKey: 'value',
        source: referenceByCitation.ttAdapter(),
      }
    )
      .on('typeahead:selected', function ($e, datum) {
        $('#instance_reference_id').val(datum.id);
      })
      .on('typeahead:closed', function ($e, datum) {
        // NOOP: cannot distinguish tabbing through vs emptying vs typing text.
        // Users must select.
      })
      .on('typeahead:rendered', function () {
        console.log('Typeahead initialization completed, lock released.');
        window.typeaheadLock = false;  // Release lock after rendering completes
      });

    // Mark the element as initialized to avoid reinitialization
    $(this).data('typeahead-initialized', true);  
  });
}

window.setUpInstanceReferenceFoa = setUpInstanceReferenceFoa 

// constructs the suggestion engine
window.referenceByCitation = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  remote: window.relative_url_root + '/references/typeahead/on_citation?term=%QUERY',
  limit: 100
});

// kicks off the loading/processing of `local` and `prefetch`
referenceByCitation.initialize();

window.referenceByCitation = referenceByCitation;

