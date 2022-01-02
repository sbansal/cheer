import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {

  toggleWeeklySummary(event) {
    console.log(event)
    document.getElementById('weekly-summary-form').submit()
    event.preventDefault()
  }
}
