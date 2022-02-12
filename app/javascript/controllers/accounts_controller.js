import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"
import Chart from 'chart.js/auto'
import { getRelativePosition } from 'chart.js/helpers';
import {LineController} from 'chart.js'

export default class extends Controller {
  static targets = [ "source", "errorMessage", "destination", "dropdown"]

  loadFields(event) {
    const value = document.querySelector("input[name=account_category]:checked").value
    for(let element of document.getElementsByClassName('account-fields')) {
      console.log(element.id)
      console.log(`${value}-fields`)
      if(element.id == `${value}-fields`) {
        element.classList.remove('hide')
      } else {
        element.classList.add('hide')
      }
    }
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
    } else {
      if (this.data.get("inView") == "false") {
        this.dropdownTarget.classList.add('hide')
      }
    }
    event.preventDefault()
  }

  allowNumbersOnly(event) {
    var charCode = (event.which) ? event.which : event.keyCode
    var fieldValue = event.target.value
    fieldValue = fieldValue.replace(/\D/g, "")
    fieldValue = fieldValue.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
    if (fieldValue.length > 0) {
      event.target.value = '$' + fieldValue
    }
  }

  validateSubmit(event) {
    var button = document.getElementById('submit-button')
    if (document.getElementById('name').value.length > 0
      && document.getElementById('balance').value.length > 0) {
      button.disabled = false
    } else {
      button.disabled = true
    }
  }

  validateFormFields(event) {
    var form = event.target.form
    if(form.length == 0) {
      return;
    } else {
      var button = event.target.form.querySelector('input[type="submit"]')
      var requiredInputElements = event.target.form.querySelectorAll('input[type="text"]')
      requiredInputElements = Array.prototype.slice.call(requiredInputElements)
      const disabled = requiredInputElements.some((element) => element.value.length == 0)
      if (button) {
        button.disabled = disabled
      }
    }
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