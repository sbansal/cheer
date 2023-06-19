import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  clearPlaidLocalCache() {
    localStorage.removeItem('plaid_oauth_initiated')
    localStorage.removeItem('plaid_link_token')
    localStorage.removeItem('plaid_update_mode')
  }

  processPlaidEvent(eventName, metadata) {
    if (eventName === 'HANDOFF') {
      this.clearPlaidLocalCache()
    } else if (eventName === 'OPEN_OAUTH') {
      console.debug('Initiating oauth flow')
      localStorage.setItem('plaid_oauth_initiated', 'true')
    } else if (eventName === 'FAIL_OAUTH' || eventName === 'CLOSE_OAUTH') {
      this.clearPlaidLocalCache()
    }
  }

  updateLoginItem(event) {
    console.debug('#updateLoginItem')
    let self = this
    let token;
    if (localStorage.getItem('plaid_link_token')) {
      token = localStorage.getItem('plaid_link_token')
    } else {
      token = this.element.dataset['token']
      localStorage.setItem('plaid_link_token', token)
      localStorage.setItem('plaid_update_mode', 'true')
    }
    let configs = {
      token: token,
      onSuccess: async function(public_token, metadata) {
        fetch('/plaid/update_link', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ link_token: token}),
        })
      },
      onExit: async function(err, metadata) {
        if (err != null) {
          console.error("Error: ", err)
        }
        self.clearPlaidLocalCache()
      },
      onEvent: async function(eventName, metadata) {
        console.debug("Event name == " + eventName)
        self.processPlaidEvent(eventName, metadata)
      },
    }
    if (localStorage.getItem('plaid_oauth_initiated')) {
      configs['receivedRedirectUri'] = window.location.href
    }
    var linkHandler = Plaid.create(configs)
    linkHandler.open()
    if (event) {
      event.preventDefault()
    }
  }

  async createLoginItem(event) {
    console.debug('#createLoginItem')
    let self = this
    const fetchLinkToken = async () => {
      if (localStorage.getItem('plaid_link_token')) {
        return localStorage.getItem('plaid_link_token')
      } else {
        const response = await fetch('/plaid/create_link_token', { method: 'POST' })
        const responseJSON = await response.json();
        localStorage.setItem('plaid_link_token', responseJSON.link_token)
        return responseJSON.link_token
      }
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
          console.error("Error: ", err)
          if (err.error_code === 'INVALID_LINK_TOKEN') {
            linkHandler.destroy();
            linkHandler = Plaid.create({
              ...configs,
              token: await fetchLinkToken(),
            })
          }
        }
        self.clearPlaidLocalCache()
        location.reload()
      },
      onEvent: async function(eventName, metadata) {
        console.debug("Event name == " + eventName)
        self.processPlaidEvent(eventName, metadata)
      },
    }
    if (localStorage.getItem('plaid_oauth_initiated')) {
      configs['receivedRedirectUri'] = window.location.href
    }
    var linkHandler = Plaid.create(configs)
    linkHandler.open()
    if (event) {
      event.preventDefault()
    }
  }

  connect() {
    console.debug('plaid connected')
    if (localStorage.getItem('plaid_link_token') && localStorage.getItem('plaid_oauth_initiated')) {
      const plaidLinkToken = localStorage.getItem('plaid_link_token')
      console.debug('Plaid link token = ' + plaidLinkToken)
      if (localStorage.getItem('plaid_update_mode')) {
        this.updateLoginItem()
      } else {
        this.createLoginItem()
      }
    } else {
      console.debug('Plaid link token not set')
      this.clearPlaidLocalCache()
    }
  }
}
