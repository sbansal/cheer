import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  turnOnAnonymousMode() {
    return document.querySelectorAll('.cheer-money').forEach(function(item) { item.innerHTML = '$0.00'})
  }
}