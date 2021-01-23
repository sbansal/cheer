import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    console.debug("Initialing keyboard controller")
    document.addEventListener('keydown', function(e) {
      //cmd + k
      if((e.ctrlKey || e.metaKey) && e.which == 75) {
        console.debug("CMD + K pressed")
      } else if (e.which == 75) {
        console.debug("K pressed")
      } else {
        console.debug("pressed - " + e.which)
      }
    })
  }
}