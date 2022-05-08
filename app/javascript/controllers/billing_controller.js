import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  togglePricing(event) {
    console.debug('togglePricing')
    if (event.target.value === 'yearly') {
      document.getElementById('price').innerHTML = '$190 per year'
      document.getElementById('discount-info').classList.remove('d-none')
    } else {
      document.getElementById('price').innerHTML = '$19 per month'
      document.getElementById('discount-info').classList.add('d-none')
    }
  }
}