import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showDetails(event) {
    console.debug("#showDetails")
    if (event.target.tagName !== 'A') {
      let detailsContainer = document.getElementById(`link-details-${event.params.id}`)
      if (detailsContainer) {
        detailsContainer.classList.toggle('hide')
        detailsContainer.classList.toggle('primary-900-bg')
      }
    }
  }
}
