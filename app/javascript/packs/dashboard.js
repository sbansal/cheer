$(document).ready(function() {
  $(document).on('click', '.tx-row', function(event) {
    $('#tx-details-' + $(this).data('id')).toggle('slow');
  });
  
  $(document).on('click', '.category-row', function(event) {
    var category_desc = $(this).find('.category-desc').text();
    $.ajax({
      url: '/dashboard/transactions',
      data: { 
        start: $('#start').val(),
        end: $('#end').val(),
        category_desc: category_desc,
        cashflow_type: $(this).data('cashflow-type'),
        essential: $(this).data('essential'),
      }
    });
    return false;
  });
});