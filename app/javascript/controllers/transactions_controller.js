import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {

  showTransactions(event) {
    console.debug("#showTransactions")
    this.element.classList.toggle('primary-900-bg')
    this.element.querySelector('.transactions-summary').classList.toggle('hide')
    event.preventDefault()
  }

  renderForm(event) {
    console.debug("#renderForm")
    document.getElementById(event.target.dataset.target).innerHTML = event.detail[0].body.innerHTML
  }

  fetchTransactionDetails(event) {
    console.debug("#fetchTransactionDetails")
    const transactionId = this.element.dataset.txId
    Rails.ajax({
      url: "/transactions/" + transactionId,
      type: "GET",
      success: function(data) {},
      error: function(data) {}
    })
    event.preventDefault()
  }

  search(event) {
    console.debug("#search")
    document.getElementById('transactions-container').innerHTML = ""
    document.getElementById('spinner-container').classList.toggle('hide')
    if(event.target.value.length > 0) {
      Rails.ajax({
        url: "/transactions?search_query=" + event.target.value,
        type: "GET",
        dataType: 'script',
        success: function(data) {},
        error: function(data) {},
        complete: function(data) {
          console.debug("hiding spinner - search TX")
          document.getElementById('spinner-container').classList.toggle('hide')
        },
      })
    } else {
      Rails.ajax({
        url: "/transactions",
        type: "GET",
        dataType: 'script',
        success: function(data) {},
        error: function(data) {},
        complete: function(data) {
          console.debug("hiding spinner - ALL TX")
          document.getElementById('spinner-container').classList.toggle('hide')
        }
      })
    }
    event.preventDefault()
  }
}