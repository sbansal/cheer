import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = ['container']

  showTransactions(event) {
    this.element.classList.toggle('primary-900-bg')
    this.element.querySelector('.transactions-summary').classList.toggle('hide')
    event.preventDefault()
  }
}