import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"
import {triggerToast} from "../utils.js"

export default class extends Controller {
  static targets = [ "essentialMenuItem", "bulkEssentialMenuItem"]
  static values = {
    period: String,
  }

  showTransactions(event) {
    console.debug("#showTransactions")
    if (event.delegateTarget?.tagName !== 'A' && !event.delegateTarget?.classList.contains('no-bubble')) {
      this.element.classList.toggle('primary-900-bg')
      this.element.querySelector('.transactions-summary').classList.toggle('hide')
      event.stopPropagation()
    }
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
      var transactionUrl = `/transactions?period=${this.periodValue}`
      if(event.target.value.length > 0) {
        transactionUrl = `/transactions?period=${this.periodValue}&search_query=${event.target.value}`
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

  updateTransactions(transactionId, formData) {
    Rails.ajax({
      url: "/transactions/" + transactionId,
      type: "PUT",
      dataType: 'script',
      contentType: 'application/json',
      data: formData,
      success: function(data) {
        triggerToast(document.getElementsByClassName('toast')[0])
      },
      error: function(data) {},
      complete: function(data) {
        var start = document.getElementById('start')
        var end = document.getElementById('end')
        if (start && end) {
          Rails.ajax({
            url: `/expenses?start=${start.value}&end=${end.value}`,
            type: 'GET',
            dataType: 'script',
            success: function(data) {},
            error: function(data) {},
            complete: function(data) {}
          })
        }
      },
    })
  }

  toggleEssentialSpend(event) {
    console.debug("#toggleEssentialSpend")
    let transactionId = this.essentialMenuItemTarget.getAttribute('data-id')
    let essentialValue = this.essentialMenuItemTarget.getAttribute('data-value')
    var formData = new FormData()
    formData.append("transaction[essential]", `${essentialValue}`)
    this.updateTransactions(transactionId, formData)
    event.preventDefault()
  }

  toggleBulkEssentialSpend(event) {
    console.debug("#toggleBulkEssentialSpend")
    let transactionId = this.bulkEssentialMenuItemTarget.getAttribute('data-id')
    let essentialValue = this.bulkEssentialMenuItemTarget.getAttribute('data-value')
    var formData = new FormData()
    formData.append("transaction[essential]", `${essentialValue}`)
    formData.append("bulk_update", true)
    this.updateTransactions(transactionId, formData)
    event.preventDefault()
  }
}
