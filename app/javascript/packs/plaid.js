$(document).ready(function() {
  var initializeHandler = function() {
    return Plaid.create({
      clientName: 'cheer',
      countryCodes: ['US'],
      env: $('meta[name=plaid-env]').attr("content"),
      key: $('meta[name=plaid-pk]').attr("content"),
      product: ['transactions'],
      language: 'en',
      webhook: location.origin + '/events/login_item_callback',
      onSuccess: function(public_token, metadata) {
        $.ajax({
          type: 'POST',
          url: '/plaid/get_access_token',
          data: {
            public_token: public_token,
          },
          dataType: 'json',
        }).done(function(data, textStatus, jqXHR) {
          location.reload();
        }).fail(function(jqXHR, textStatus, errorThrown) {
          console.log("Fail - " + textStatus);
          console.log("Error Thrown - " + errorThrown);
        });
      },
      onExit: function(err, metadata) {
        if (err != null) {
          console.log("OnExit - " + err);
        }
      }
    });
  }

  $(document).on('click', '#plaid-link', function(event) {
    console.log("Clicked plaid link");
    event.preventDefault();
    var handler = initializeHandler();
    handler.open();
  });

  $(document).on('click', '#connect-link', function(event) {
    console.log("Clicked connect link");
    event.preventDefault();
    var handler = initializeHandler();
    handler.open();
  });
});
