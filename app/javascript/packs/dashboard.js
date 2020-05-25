$(document).ready(function() {
  $(document).on('click', '.tx-row', function(event) {
    $('#tx-details-' + $(this).data('id')).toggle('slow');
  });
});