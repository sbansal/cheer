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
    if (document.getElementById('transaction_category_name')) {
      document.getElementById('transaction_category_name').select()
    }
  }

  search(event) {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      console.debug("#search")
      var transactionContainer = document.getElementById('transactions-container')
      transactionContainer.innerHTML = ""
      transactionContainer.style.opacity = 0
      document.getElementById('spinner-container').classList.toggle('hide')
      var transactionUrl = "/transactions"
      if(event.target.value.length > 0) {
        transactionUrl = "/transactions?search_query=" + event.target.value
      }
      Rails.ajax({
        url: transactionUrl,
        type: "GET",
        dataType: 'script',
        success: function(data) {},
        error: function(data) {},
        complete: function(data) {
          console.debug("hiding spinner - search TX")
          document.getElementById('spinner-container').classList.toggle('hide')
          transactionContainer.style.opacity = 1
        },
      })
    }, 500)
    event.preventDefault()
  }
}
