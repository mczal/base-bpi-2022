import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  handleChange(){
    const path = this.path.replace(/\-1/, `${this.element.value}`);
    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions);
  }

  handleSuccess(responseText){
    this.fixedRatesOptionElement.innerHTML = responseText;
  }
  handleDone(){
    window.KTApp.unblockPage();
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }

  get fixedRatesOptionElement(){
    if(this._fixedRatesOptionElement){
      return this._fixedRatesOptionElement;
    }
    this._fixedRatesOptionElement = this.element.closest('form')
      .querySelector('.js-fixed-rates-options');

    return this._fixedRatesOptionElement;
  }

  get ajaxOptions(){
    return {
      onFail: this.handleFail.bind(this),
      onDone: this.handleDone.bind(this),
      onSuccess: this.handleSuccess.bind(this),
      headers: [
        {
          key: 'Content-Type',
          value: 'application/json'
        },
        {
          key: 'X-CSRF-Token',
          value: window.Util.getCsrfToken()
        },
      ]
    };
  }
}
