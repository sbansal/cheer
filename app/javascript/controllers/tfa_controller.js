import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {

  toggle(event) {
    console.log("toggling 2FA")
    const enable_tfa = document.getElementById('tfa-switcher').checked
    if (enable_tfa) {
      Rails.ajax({
        url: "/two_factor_authentication/new",
        type: "GET",
        success: function(data) {},
        error: function(data) {}
      })
    } else {
      Rails.ajax({
        url: "/two_factor_authentication",
        type: "DELETE",
        success: function(data) {},
        error: function(data) {}
      })
    }
    event.preventDefault()
  }
}