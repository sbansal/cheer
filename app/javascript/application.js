// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"

// UJS
import Rails from "@rails/ujs"
Rails.start()
import "@popperjs/core"
import * as bootstrap from "bootstrap"
import {Toast} from 'bootstrap'
import {triggerToast} from "./utils.js"
import "chart.js"


document.addEventListener("turbo:load", function() {
  console.debug("turbo!")
  var toastElList = [].slice.call(document.querySelectorAll('.toast'))
  toastElList.map(function (toastEl) {
    triggerToast(toastEl)
  })

  var tooltipList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipList.map(function (tooltipEl) {
    return new bootstrap.Tooltip(tooltipEl)
  })
})

