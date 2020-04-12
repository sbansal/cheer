var handler = Plaid.create({
  clientName: 'cheer',
  countryCodes: ['US'],
  env: 'sandbox',
  key: 'c2e1ee0a92965331268d3fc4473ba7',
  product: ['transactions'],
  // webhook: 'https://requestb.in',
  language: 'en',
  // userLegalName: 'John Appleseed',
  // userEmailAddress: 'jappleseed@yourapp.com',
  onLoad: function() {
    // Optional, called when Link loads
  },
  onSuccess: function(public_token, metadata) {
    console.log("-------- onSuccess ----------------");
    console.log(public_token);
    fetch('/plaid/get_access_token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(
        { 
          public_token: public_token,
          authenticity_token: document.getElementById('plaid-link').getAttribute('data-authentication-token'),
        }
      ),
    })
    .then((response) => response.json())
    .then((result) => {
      console.log('Success:', result);
    })
    .catch((error) => {
      console.error('Error:', error);
    });
    console.log(metadata);
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

const plaidLinkHandler = function(event) {
  event.preventDefault();
  handler.open();
};

window.addEventListener('load', (event) => {
    var linkElement = document.getElementById('plaid-link');
    linkElement.addEventListener('click', plaidLinkHandler);
});
