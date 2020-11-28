import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = [ "source", "errorMessage", "destination", "dropdown"]

  loadFields(event) {
    const value = document.querySelector("input[name=account_category]:checked").value
    Rails.ajax({
      url: '/bank_accounts/new?account_type='+value,
      type: 'GET',
      dataType: 'script',
      success: function(data) {},
      error: function(data) {}
    })
    event.preventDefault()
  }

  trackIn(event) {
    this.data.set("inView", true)
  }

  trackOut(event) {
    this.data.set("inView", false)
  }

  toggleDropdown(event) {
    if (event.type == 'focus') {
      this.dropdownTarget.classList.remove('hide')
    } else if (event.type == 'blur'){
      //TODO implement this
    } else {
      if (this.data.get("inView") == "false") {
        this.dropdownTarget.classList.add('hide')
      }
    }
    event.preventDefault()
  }

  showTypes(event) {
    var accountType = event.target.dataset['accountType']
    if (accountType == null) {
      accountType = event.target.closest('.superitem').dataset['accountType']
    }
    const ulElement = document.getElementById(accountType)
    ulElement.classList.toggle('hide')
    event.preventDefault()
  }

  selectItem(event) {
    this.dropdownTarget.classList.add('hide')
    document.getElementById('account_subtype').value = event.target.dataset['subtypeName']
    document.getElementById('account_type').value = event.target.parentElement.dataset['accountTypeName']
    const accountTypeDesc = event.target.parentElement.dataset['accountTypeDescription']
    const subTypeDesc = event.target.dataset['subtypeDescription']
    document.getElementById('account_type_field').value = accountTypeDesc + " > " + subTypeDesc
    event.preventDefault()
  }
}