$(document).ready(function() {
  var initializeHandler = function() {
    return Plaid.create({
      clientName: 'cheer',
      countryCodes: ['US'],
      env: $('meta[name=plaid-env]').attr("content"),
      key: $('meta[name=plaid-pk]').attr("content"),
      product: ['transactions'],
      // webhook: 'https://requestb.in',
      language: 'en',
      // userLegalName: 'John Appleseed',
      // userEmailAddress: 'jappleseed@yourapp.com',
      onLoad: function() {
        console.log("-------- onLoad ----------------");
      },
      onSuccess: function(public_token, metadata) {
        console.log("-------- onSuccess ----------------");
        console.log(public_token);
        console.log(metadata);
        $.ajax({
          type: 'POST',
          url: '/plaid/get_access_token',
          data: {
            public_token: public_token,
            authenticity_token: $('.connect-link').attr('data-authentication-token'),
          },
          dataType: 'json',
        }).done(function(data, textStatus, jqXHR) {
          console.log(textStatus);
          console.log(data);
          location.reload();
        }).fail(function(jqXHR, textStatus, errorThrown) {
          console.log(textStatus);
          console.log(errorThrown);
        });
        console.log("------------------------");
      },
      onExit: function(err, metadata) {
        console.log("-------- onExit ----------------");
        if (err != null) {
          // The user encountered a Plaid API error prior to exiting.
          console.log(err);
        }
        console.log(metadata);
        console.log("------------------------");
      },
      onEvent: function(eventName, metadata) {
        console.log("-------- OnEvent ----------------");
        console.log(eventName);
        console.log(metadata);
        console.log("------------------------");
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
