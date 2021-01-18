import { Controller } from "stimulus"

export default class extends Controller {
  toggle(event) {
    console.debug("toggle Nav")
    document.getElementById('nav-container').classList.toggle('side-nav-hidden')
    document.getElementById('nav-container').classList.toggle('side-nav-visible')
    document.body.classList.toggle('noscroll')
    event.stopPropagation()
  }
}