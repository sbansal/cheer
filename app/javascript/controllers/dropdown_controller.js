import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['timePeriodList', 'accountList']
  static classes = [ 'listSearch' ]
  static values ={
    selectedTarget: String,
  }

  bubbleEvent(data, type) {
    console.debug('#bubbleEvent')
    this.element.dispatchEvent(new CustomEvent("filterChanged", {
      detail: {
        data: data,
        type: type,
      },
      bubbles: true,
    }));
  }

  hideLists() {
    if (this.hasTimePeriodListTarget) {
      console.debug('#hideLists - time period')
      this.timePeriodListTarget.classList.add('hide')
    }
    if (this.hasAccountListTarget) {
      console.debug('#hideLists - account')
      this.accountListTarget.classList.add('hide')
    }
  }

  resetListItems(list) {
    console.debug('#resetListItems')
    list.forEach(function(element, index) {
      element.classList.remove('hide')
    });
  }

  updateTimePeriodsPicker(event) {
    console.debug('#time-period-item')
    let value = event.target.value.toLowerCase();
    if (value.length > 0) {
      document.querySelectorAll(`.${this.listSearchClass}`).forEach(function(element, index) {
        if (element.innerText.toLowerCase().includes(value)) {
          element.classList.remove('hide')
        } else {
          element.classList.add('hide')
        }
      });
    } else {
      this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
    }
  }

  updateAccountsPicker(event) {
    console.debug('#account-item')
    let value = event.target.value.toLowerCase();
    if (value.length > 0) {
      document.querySelectorAll(`.${this.listSearchClass}`).forEach(function(element, index) {
        if (element.innerText.toLowerCase().includes(value)) {
          element.classList.remove('hide')
        } else {
          element.classList.add('hide')
        }
      });
    } else {
      this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
    }
  }

  resetAllLists(targets) {
    console.debug('#resetAllLists')
    targets.forEach(function(element, index) {
      element.classList.add('hide')
    });
  }

  showList(event) {
    console.debug('#showList')
    this.resetAllLists(document.querySelectorAll("[data-dropdown-target]"))
    let targetList = document.querySelector(`[data-dropdown-target="${event.params.target}"]`)
    const boundingArea = event.currentTarget.getBoundingClientRect();
    console.debug(boundingArea)
    let minWidth = 175;
    if (targetList) {
      targetList.classList.remove('hide')
      targetList.style.top = `${boundingArea.top + boundingArea.height}px`;
      targetList.querySelector('input').focus()
    }
    event.preventDefault();
    event.stopPropagation();
  }

  chooseTarget(targetValue, dataset, type) {
    console.debug('#chooseTarget')
    document.getElementById(this.selectedTargetValue).innerText = targetValue;
    this.bubbleEvent({params: { ...dataset }}, type)
  }

  selectTimePeriod(event) {
    console.debug('#selectItem')
    let dataset = event.currentTarget.dataset
    console.debug(dataset)
    this.chooseTarget(dataset.value, [dataset], 'period')
    this.hideLists()
    event.preventDefault();
  }

  selectAccountItems(event) {
    console.debug('#selectMultipleItem')
    let selectedItems = document.querySelectorAll(`.searchable-list .form-check-input:checked`)
    let dataset = []
    let targetValue = 'All accounts'
    for(let item of selectedItems) {
      dataset.push(item.dataset)
    }
    if (selectedItems.length == 1) {
      targetValue = selectedItems[0].dataset.value
    } else if (selectedItems.length > 1) {
      targetValue = `${selectedItems.length} accounts selected.`
    }
    console.debug(dataset)
    this.chooseTarget(targetValue, dataset, 'account')
    event.preventDefault();
  }

  keyboardActions(event) {
    console.debug('#keyboardActions')
    if (event.keyCode == 13) {
      for(let element of document.querySelectorAll(`.${this.listSearchClass}`)) {
        if (!element.classList.contains('hide')) {
          console.debug('enter key pressed')
          let dataset, type;
          if (this.selectedTargetValue === 'selected-account') {
            type = 'account'
            element.querySelector('.form-check-input').click()
            this.selectAccountItems(event)
          } else {
            type = 'period'
            dataset = element .dataset
            this.chooseTarget(dataset.value, [dataset], type)
          }
          break;
        }
      }
      this.hideLists()
      event.target.value = ''
      this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
      event.preventDefault()
    } else if (event.keyCode == 27) {
      console.debug('esc key pressed')
      event.target.value = ''
      this.resetListItems(document.querySelectorAll(`.${this.listSearchClass}`))
      this.resetAllLists(document.querySelectorAll("[data-dropdown-target]"))
      event.preventDefault()
    }

  }

  connect() {
    let self = this
    document.addEventListener('click', function(event) {
      if (!event.target.closest('.searchable-list')) {
        console.debug('clicked outside')
        self.resetAllLists(document.querySelectorAll("[data-dropdown-target]"))
      }
    })
  }
}
