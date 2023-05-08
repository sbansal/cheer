import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  submitForm(event) {
    console.debug("#submitForm")
    const form = this.formTarget;
    const url = form.action;
    const method = form.method;
    const data = new FormData(form);
    console.debug("data", data)
    if (document.getElementById('message_content').value === "") {
      return false
    } else {
      fetch(url, {
        method: method,
        body: data
      })
      .then(response => response.text())
      .then(html => {
        // handle successful response
        this.resetForm();
      })
      .catch(error => {
        // handle error
      });
    }
  }

  submitOnEnter(event) {
    if (event.key === "Enter") {
      console.debug("#submitOnEnter")
      event.preventDefault()
      this.submitForm(event)
      return false
    }
  }

  resetForm() {
    const form = this.formTarget;
    form.reset();
  }


}
  