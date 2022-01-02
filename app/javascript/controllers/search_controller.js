import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = [ "query", "selection", "results", "hiddenSelection" ]

  addressLookup(event) {
    var query = this.queryTarget.value
    if (query.length > 3) {
      Rails.ajax({
        url: "/search/address?query="+ query,
        type: "get",
        success: function(data) {},
        error: function(data) {}
      })
    }
    event.preventDefault()
  }

  selectItem(event) {
    this.queryTarget.value = this.selectionTarget.dataset.selection
    this.resultsTarget.textContent = ''
    event.preventDefault()
  }
}