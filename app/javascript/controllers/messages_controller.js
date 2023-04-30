import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  submit(event) {
    console.debug("#submit")
    const form = this.formTarget;
    const url = form.action;
    const method = form.method;
    const data = new FormData(form);

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

  submitOnEnter(event) {
    console.debug("#submitOnEnter")
    if (event.key === "Enter") {
      event.preventDefault()
      this.submit(event)
    }
  }

  resetForm() {
    const form = this.formTarget;
    form.reset();
  }


}
  