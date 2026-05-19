(function() {
  $(document).on("turbo:load", function() {
    $('body').on('click', 'a.confirm-delete-btn', function() {
      var $btn = $(this);
      $btn.attr('disabled', 'disabled')
          .html('<i class="fa fa-spinner fa-spin"></i> ' + $btn.text().trim());
      $btn.siblings('.cancel-link').attr('disabled', 'disabled');
    });
  });
}).call(this);
