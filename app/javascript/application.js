// Entry point for the build script in your package.json
import "./controllers"
import "./channels"
import "@rails/ujs"
// import "@rails/activestorage"
import "uplot"
import * as bootstrap from "bootstrap"
import "@popperjs/core"
import "@hotwired/turbo-rails"
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

// require("@rails/ujs").start()
// require("@rails/activestorage").start()
// require("channels")
// require("uplot")
// require("bootstrap")
// require("@popperjs/core")
// require("@hotwired/turbo-rails")
//
// import {Toast} from 'bootstrap'
// import "controllers"
// import {triggerToast} from "../packs/utils.js"
//
// document.addEventListener("turbo:load", function() {
//   console.debug("turbo!")
//   var toastElList = [].slice.call(document.querySelectorAll('.toast'))
//   toastElList.map(function (toastEl) {
//     triggerToast(toastEl)
//   })
// })
