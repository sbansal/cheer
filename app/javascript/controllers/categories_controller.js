import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = [ "results"]

  search(event) {
    console.debug("#search")
    var transactionId = event.target.dataset.txId
    if(event.target.value.length > 0) {
      Rails.ajax({
        url: '/categories?query=' + event.target.value + '&transaction_id=' + transactionId,
        type: 'GET',
        dataType: 'script',
        success: function(data) {},
        error: function(data) {}
      })
    } else {
      document.getElementById(`categories-container-tx-${transactionId}`).innerHTML = ""
    }
  }

  empty(event) {
    console.debug("empty")
    var categoryElements = document.querySelectorAll('.categories-container')
    categoryElements.forEach(function(categoryElement) {
      categoryElement.innerHTML = ""
    })
  }

  select(event) {
    console.debug("select")
    var id = event.target.closest('li').dataset.id
    this.element.querySelector('#transaction_category_id').value = id
    this.element.querySelector('#transaction_category_name').value = event.target.textContent
    this.empty(event)
    event.stopPropagation()
  }
}