import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"
import {triggerToast} from "../utils.js"

export default class extends Controller {
  static targets = [ "essentialMenuItem", "bulkEssentialMenuItem", "timePeriodPicker", "accountsPicker", "search"]
  static values = {
    period: String,
    query: String,
    accountIds: Array,
  }

  handleEvent(event) {
    let data = event.detail.data
    const type = event.detail.type
    if (type === 'period') {
      this.periodValue = data.params[0].period
    } else if (type === 'account') {
      let accountIds = new Set()
      for (const key in data.params) {
        const param = data.params[key]
        if (param.accountId) {
          accountIds.add(param.accountId)
        }
      }
      this.accountIdsValue = Array.from(accountIds)
    }
  }

  periodValueChanged(value, prevValue) {
    if (prevValue) {
      this.search()
    }
  }

  accountIdsValueChanged(value, prevValue) {
    if (prevValue) {
      this.search()
    }
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

  buildSearchParams(data) {
    const params = new URLSearchParams()
    Object.entries(data).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach(value => params.append(key+'[]', value.toString()))
      } else {
        params.append(key, value.toString())
      }
    })
    return params.toString()
  }

  search(event) {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      console.debug("#search")
      var transactionContainer = document.getElementById('transactions-container')
      transactionContainer.innerHTML = ""
      transactionContainer.style.opacity = 0
      this.queryValue = this.searchTarget.value
      let data = {
        period: this.periodValue,
        search_query: this.queryValue,
        bank_account_id: this.accountIdsValue,
      }
      const params = this.buildSearchParams(data)
      document.getElementById('spinner-container').classList.toggle('hide')
      let transactionUrl = `/transactions?${params}`
      Rails.ajax({
        url: transactionUrl,
        type: "GET",
        dataType: 'script',
        success: function(data) {
          document.getElementById('spinner-container').classList.add('hide')
        },
        error: function(data) {
          document.getElementById('spinner-container').classList.add('hide')
        },
        complete: function(data) {
          console.debug("hiding spinner - search TX")
          document.getElementById('spinner-container').classList.add('hide')
          transactionContainer.style.opacity = 1
        },
      })
    }, 500)
    if (event) {
      event.preventDefault()
    }
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
