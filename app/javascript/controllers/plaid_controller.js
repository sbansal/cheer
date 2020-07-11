import { Controller } from "stimulus"

export default class extends Controller {

  updateLoginItem(event) {
    event.preventDefault()
    var linkHandler = Plaid.create({
      env: document.querySelector('meta[name="plaid-env"]').content,
      key: document.querySelector('meta[name="plaid-pk"]').content,
      clientName: 'cheer',
      product: ['transactions'],
      token: this.element.dataset['token'],
      onSuccess: function(public_token, metadata) {
        console.log(metadata)
        fetch('/plaid/update_link', {
          method: 'POST',
          body: JSON.stringify({
            public_token: public_token,
          }),
          headers: {
            'Content-type': 'application/json; charset=UTF-8'
          }
        }).then(function (response) {
          if (response.ok) {
            return response.json();
          }
          return Promise.reject(response);
        }).then(function (data) {
          console.log(data);
        }).catch(function (error) {
          console.warn('Something went wrong.', error);
        });
      },
      onExit: function(err, metadata) {
        if (err != null) {
          console.log("Error - (" + err)
        }
      }
    });
    linkHandler.open()
  }


}
