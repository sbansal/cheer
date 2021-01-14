import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = [ "subCategoriesContainer", "results"]

  showCategoriesDropdown(event) {
    console.log("#showCategoriesDropdown")
    this.resultsTarget.classList.remove("hide")
  }

  fetchChildCategories(event) {
    console.log("#fetchChildCategories")
    Rails.ajax({
      url: event.target.closest('li').dataset.categoriesUrlValue,
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        console.log(data)
        var li = event.target.dataset.categoriesTarget
      },
      error: function(data) {}
    })
  }
}