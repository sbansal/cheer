import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    const nav = document.getElementById('nav-container')
    document.addEventListener('click', function(event) {
      if(document.body.classList.contains('noscroll') && !nav.contains(event.target)) {
        console.log("page click")
        document.getElementById('nav-container').classList.remove('side-nav-visible')
        document.getElementById('nav-container').classList.add('side-nav-hidden')
        document.body.classList.remove('noscroll')
      }
    })
  }
}