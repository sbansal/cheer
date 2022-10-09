import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {

  toggleWeeklySummary(event) {
    document.getElementById('weekly-summary-form').submit()
    event.preventDefault()
  }

  toggleSubscription(event) {
    document.getElementById(`notification-template-${event.params.templateId}`).submit()
    event.preventDefault()
  }
}
