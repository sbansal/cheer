import { Controller } from "stimulus"

export default class extends Controller {

  updateLoginItem(event) {
    var token = this.element.dataset['token']
    var linkHandler = Plaid.create({
      token: token,
      onSuccess: function(public_token, metadata) {
        fetch('/plaid/update_link', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ link_token: token}),
        })
      },
      onExit: function(err, metadata) {
        console.debug(metadata)
        if (err != null) {
          console.error("Error: ", error)
        }
      },
      onEvent: async function(eventName, metadata) {
        if (eventName === 'HANDOFF') {
          location.href = '/login_items'
        }
      },
    })
    linkHandler.open()
    event.preventDefault()
  }

  createLoginItem(event) {
    (async function() {
      const fetchLinkToken = async () => {
        const response = await fetch('/plaid/create_link_token', { method: 'POST' })
        const responseJSON = await response.json();
        return responseJSON.link_token;
      };
      const configs = {
        token: await fetchLinkToken(),
        onSuccess: async function(public_token, metadata) {
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
          location.reload()
        },
        onEvent: async function(eventName, metadata) {
          if (eventName === 'HANDOFF') {
            location.href = '/login_items'
          }
        },
      }
      var linkHandler = Plaid.create(configs)
      linkHandler.open()
    })()
    event.preventDefault()
  }

}
