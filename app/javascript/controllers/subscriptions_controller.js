import { Controller } from "stimulus"

export default class extends Controller {

  hideDetails(event) {
    console.debug("subscriptions#hideDetails")
    document.querySelector('.slide-in').classList.remove('show')
    document.getElementById('subscription-details').innerHTML = ""
    event.preventDefault()
  }
}