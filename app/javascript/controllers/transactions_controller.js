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

  deselectRow() {
    console.debug("#deselectRow")
    let selectedRow = document.querySelector('[data-tx-select]')
    if (selectedRow) {
      selectedRow.classList.remove('primary-900-bg')
      selectedRow.removeAttribute('data-tx-select')
    }
  }

  selectRow(transactionId) {
    console.debug("#selectRow")
    var parentElement = document.getElementById(`tx-${transactionId}`)
    if (parentElement) {
      parentElement.classList.add('primary-900-bg')
      parentElement.setAttribute('data-tx-select', true)
    }
  }

  showTransactionDetails() {
    console.debug("#showTransactionDetails")
    const container = document.getElementById('transaction-details')
    container.querySelector('div.slide-in').classList.add('show')
  }

  fetchTransactionDetails(event) {
    console.debug("#fetchTransactionDetails")
    console.log(this.element.getBoundingClientRect())
    const transactionId = this.element.dataset.txId
    const topValue = this.element.getBoundingClientRect().top
    if (this.element.dataset.txSelect) {
      return;
    }
    let _this = this
    _this.deselectRow()
    _this.selectRow(transactionId)
    Rails.ajax({
      url: "/transactions/" + transactionId,
      type: "GET",
      success: function(data) {
        //slide-in
        let container = document.getElementById('transaction-details')
        container.querySelector('div.slide-in').style.width = (container.clientWidth - 20) + "px"
        container.querySelector('div.slide-in').style.top = (window.scrollY + 50) + "px"
        //show
        _this.showTransactionDetails()
      },
      error: function(data) {}
    })
    event.preventDefault()
  }

  hideTransactionDetails(event) {
    console.debug("#hideTransactionDetails")
    document.querySelector('.slide-in').classList.remove('show')
    document.getElementById('transaction-details').innerHTML = ""
    // this.deselectRow()
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