import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['timePeriodList', 'accountList']
  static classes = [ 'listSearch' ]
  static values ={
    selectedTarget: String,
  }

  hideLists() {
    if (this.hasTimePeriodListTarget) {
      this.timePeriodListTarget.classList.add('hide')
    }
    if (this.hasAccountListTarget) {
      this.accountListTarget.classList.add('hide')
    }
  }

  resetListItems(list) {
    list.forEach(function(element, index) {
      element.parentElement.classList.remove('hide')
    });
  }

  updateTimePeriodsPicker(event) {
    console.log('#time-period-item')
    let value = event.target.value.toLowerCase();
    if (value.length > 0) {
      document.querySelectorAll(`.${this.listSearchClass}`).forEach(function(element, index) {
        if (element.innerText.toLowerCase().includes(value)) {
          element.parentElement.classList.remove('hide')
        } else {
          element.parentElement.classList.add('hide')
        }
      });
    } else {
      this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
    }
  }

  resetAllLists(targets) {
    targets.forEach(function(element, index) {
      element.classList.add('hide')
    });
  }

  showList(event) {
    console.log('#showList')
    this.resetAllLists(document.querySelectorAll("[data-dropdown-target]"))
    let targetList = document.querySelector(`[data-dropdown-target="${event.params.target}"]`)
    if (targetList) {
      targetList.classList.remove('hide')
      targetList.querySelector('input').focus()
    }
    event.preventDefault();
  }

  chooseTarget(target) {
    document.getElementById(this.selectedTargetValue).innerText = target.innerText;
    this.hideLists()
  }

  selectItem(event) {
    console.log('#selectItem')
    let target = event.currentTarget.querySelector(`.${this.listSearchClass}`)
    this.chooseTarget(target)
    event.preventDefault();
  }

  keyboardActions(event) {
    console.log('#keyboardActions')
    if (event.keyCode == 13) {
      for(let element of document.querySelectorAll(`.${this.listSearchClass}`)) {
        if (!element.parentElement.classList.contains('hide')) {
          console.debug('enter key pressed')
          this.chooseTarget(element)
          event.target.value = ''
          this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
          break;
        }
      }
    } else if (event.keyCode == 27) {
      console.debug('esc key pressed')
      event.target.value = ''
      this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
      this.resetAllLists(document.querySelectorAll("[data-dropdown-target]"))
    }
  }

  connect() {
    let target = document.querySelector('.filters')
    let self = this
    document.addEventListener('click', function(event) {
      if (!target.contains(event.target)) {
        console.log('clicked outside')
        self.resetAllLists(document.querySelectorAll("[data-dropdown-target]"))
      }
      event.preventDefault()
    })
  }
}
