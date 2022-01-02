// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"

// UJS
import Rails from "@rails/ujs"
Rails.start()

import "uplot"
import "@popperjs/core"
import * as bootstrap from "bootstrap"
import {Toast} from 'bootstrap'
import {triggerToast} from "./utils.js"
import {seriesBarsPlugin} from "./seriesBarPlugin.js"


document.addEventListener("turbo:load", function() {
  console.debug("turbo!")
  var toastElList = [].slice.call(document.querySelectorAll('.toast'))
  toastElList.map(function (toastEl) {
    triggerToast(toastEl)
  })
})

