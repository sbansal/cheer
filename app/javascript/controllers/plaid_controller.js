import { Controller } from "stimulus"

export default class extends Controller {

  updateLoginItem(event) {
    var linkHandler = Plaid.create({
      token: this.element.dataset['token'],
      onSuccess: function(public_token, metadata) {
        console.log(metadata)
        fetch('/plaid/update_link', {
          method: 'POST',
          body: JSON.stringify({
            public_token: public_token,
          }),
          headers: {
            'Content-type': 'application/json; charset=UTF-8'
          }
        }).then(function (response) {
          if (response.ok) {
            return response.json();
          }
          return Promise.reject(response);
        }).then(function (data) {
          console.log(data);
        }).catch(function (error) {
          console.warn('Something went wrong.', error);
        });
      },
      onExit: function(err, metadata) {
        if (err != null) {
          console.log("Error - (" + err)
        }
      }
    });
    linkHandler.open()
  }

  createLoginItem(event) {
    (async function() {
      const fetchLinkToken = async () => {
        const response = await fetch('/plaid/create_link_token', { method: 'POST' })
        const responseJSON = await response.json();
        return responseJSON.link_token;
      };
      const configs = {
        // 1. Pass a new link_token to Link.
        token: await fetchLinkToken(),
        onSuccess: async function(public_token, metadata) {
          console.log("Sending fetch request with token = " + public_token)
          console.log(metadata)
          fetch('/plaid/generate_access_token', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ public_token: public_token }),
          })
        },
        onExit: async function(err, metadata) {
          if (err != null) {
            console.error("Error: ", error)
            if (err.error_code === 'INVALID_LINK_TOKEN') {
              linkHandler.destroy();
              linkHandler = Plaid.create({
                ...configs,
                token: await fetchLinkToken(),
              })
            }
          }
          console.log("Exiting the plaid link creator.")
          location.reload()
        },
      }
      var linkHandler = Plaid.create(configs)
      linkHandler.open()
    })()
  }

}
