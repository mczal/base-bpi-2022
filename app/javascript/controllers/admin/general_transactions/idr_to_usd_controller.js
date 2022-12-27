import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.rateElement = document.querySelector('select[name="general_transaction[fixed_rates_options][id]"]');
  }

  connect(){
    this.usdElement = this.nominalContainer.querySelector('input[name*="price_usd"]');
    this.element.addEventListener('input', this.handleInput.bind(this))
  }

  handleInput(e){
    const rate = this.rateElement.selectedOptions[0].dataset.rateValue;
    const value = this.element.value.replaceAll(/\./g,'').replace(/\,/, '.');

    const res = parseFloat(value) / parseFloat(rate);
    this.usdElement.value = res;

    const event = new Event('input-price:re-init');
    this.usdElement.dispatchEvent(event);
  }

  get nominalContainer(){
    if(this._nominalContainer){
      return this._nominalContainer;
    }

    let result = this.element;
    while(!result.classList.contains('js-general-transactions-nominal-idr-usd')){
      result = result.parentElement;
    }

    this._nominalContainer = result;
    return this._nominalContainer;
  }
}
