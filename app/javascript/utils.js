import {Toast} from 'bootstrap';

export function triggerToast(toastEl) {
  console.debug('#triggerToast')
  toastEl.addEventListener('hidden.bs.toast', function () {
    console.debug('toast hidden')
    toastEl.remove()
  })
  var toaster = new Toast(toastEl)
  toaster.show()
}
