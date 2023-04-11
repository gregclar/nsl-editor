# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin "jQuery", to: "https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.js", preload: true
pin "select2", to: "https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.7/js/select2.min.js"
pin "dropdown", preload: true
pin "fresh", preload: true
pin "jquery-dateformat.min", preload: true
pin "main", preload: true
pin "new_search", preload: true
pin "tabs", preload: true
pin "typeahead_bundle"
pin "bloodhound", to: "https://cdn.jsdelivr.net/npm/typeahead.js@0.11.1/dist/bloodhound.min.js"
pin "typeahead", to: "https://cdn.jsdelivr.net/npm/typeahead.js@0.11.1/dist/typeahead.bundle.min.js"

pin "typeaheads_for_author_duplicate_of", to: "typeaheads/for_author/duplicate_of"

pin "typeaheads_for_instance_for_name_showing_reference_update", to: "typeaheads/for_instance/for_name_showing_reference_update"
pin "typeaheads_for_instance_name", to: "typeaheads/for_instance/name"
pin "typeaheads_for_instance_name_for_unpub_citation", to: "typeaheads/for_instance/name_for_unpub_citation"
pin "typeaheads_for_instance_reference", to: "typeaheads/for_instance/reference"
pin "typeaheads_for_instance_reference_excluding_current", to: "typeaheads/for_instance/reference_excluding_current"
pin "typeaheads_for_instance_synonymy", to: "typeaheads/for_instance/synonymy"

pin "typeaheads_for_loader_batch_default_reference", to: "typeaheads/for_loader_batch/default_reference"
pin "typeaheads_for_loader_name_parent", to: "typeaheads/for_loader_name/parent"
pin "typeaheads_for_orchids_parent", to: "typeaheads/for_orchids/parent"

pin "typeaheads_for_reference_author", to: "typeaheads/for_reference/author"
pin "typeaheads_for_reference_duplicate", to: "typeaheads/for_reference/duplicate"
pin "typeaheads_for_reference_parent", to: "typeaheads/for_reference/parent"

pin "typeaheads_for_name_authors_by_abbrev", to: "typeaheads/for_name/authors_by_abbrev_bloodhound"
pin "typeaheads_for_name_author", to: "typeaheads/for_name/author"
pin "typeaheads_for_name_base_author", to: "typeaheads/for_name/base_author"
pin "typeaheads_for_name_cultivar_parent", to: "typeaheads/for_name/cultivar_parent"
pin "typeaheads_for_name_cultivar_second_parent", to: "typeaheads/for_name/cultivar_second_parent"
pin "typeaheads_for_name_duplicate_of", to: "typeaheads/for_name/duplicate_of"
pin "typeaheads_for_name_ex_author", to: "typeaheads/for_name/ex_author"
pin "typeaheads_for_name_ex_base_author", to: "typeaheads/for_name/ex_base_author"
pin "typeaheads_for_name_family", to: "typeaheads/for_name/family"
pin "typeaheads_for_name_hybrid_parent", to: "typeaheads/for_name/hybrid_parent"
pin "typeaheads_for_name_parent", to: "typeaheads/for_name/parent"
pin "typeaheads_for_name_sanctioning_author", to: "typeaheads/for_name/sanctioning_author"
pin "typeaheads_for_name_second_parent", to: "typeaheads/for_name/second_parent"
pin "typeaheads_for_name_workspace_parent_name", to: "typeaheads/for_name/workspace_parent_name"
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.0.4-3/lib/assets/compiled/rails-ujs.js"
