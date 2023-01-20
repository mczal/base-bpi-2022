import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  connect(){
    $(this.baInputElement).on('select2:select', this.handleChange.bind(this));
  }

  handleChange(e){
    const path = this.path.replace(/\-1/, this.baInputElement.value);
    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions);
  }

  handleSuccess(responseText){
    const parsedResponse = JSON.parse(responseText);
    this.element.innerHTML = parsedResponse.html;
    this.priceElement.innerHTML = parsedResponse.price;
    this.priceCurrencyElement.innerHTML = parsedResponse.price_currency;
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }
  handleDone(){
    window.KTApp.unblockPage();
  }

  get ajaxOptions(){
    return {
      onDone: this.handleDone.bind(this),
      onFail: this.handleFail.bind(this),
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

  get baInputElement(){
    if(this._baInputElement){
      return this._baInputElement;
    }

    this._baInputElement = document.querySelector('select[name="invoice[invoiceable_id]"]')
    return this._baInputElement;
  }

  get priceElement(){
    return document.querySelector('.js-price');
  }
  get priceCurrencyElement(){
    return document.querySelector('.js-price-currency');
  }
}
