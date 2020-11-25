import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "source", "errorMessage", "destination" ]

  showAddress(event) {
    document.getElementById('property-data').classList.remove('hide')
  }

  hideAddress(event) {
    document.getElementById('property-data').classList.add('hide')
  }
}