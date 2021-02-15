import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static values = { id: Number}
  connect() {
    console.debug("#displayRelated")
    Rails.ajax({
      url: "/transactions/" + this.idValue + "/related",
      type: "GET",
      success: function(data) {
        console.log(data)
        document.getElementById('related-transactions-container').innerHTML = data.body.innerHTML
      },
      error: function(data) {},
      complete: function(data) {},
    })
  }

  toggle() {
    document.getElementById('related-transactions').classList.toggle('hide')
  }
}
