import { Controller } from "stimulus"

export default class extends Controller {

  toggle_target(event) {
    this.element.nextElementSibling.classList.toggle('hide')
  }
}