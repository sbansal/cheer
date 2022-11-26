import { Controller } from "@hotwired/stimulus"

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
