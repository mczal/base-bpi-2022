import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.rateElement = document.querySelector('select[name="general_transaction[fixed_rates_options][id]"]');
  }

  connect(){
    this.usdElement = this.nominalContainer.querySelector('input[name*="price_usd"]');
    this.element.addEventListener('input', this.handleInput.bind(this))
    $(this.rateElement).on('select2:select', this.handleInput.bind(this));
  }

  handleInput(e){
    let rate;
    if(this.isInputOptionCustom()){
      return;
    }

    if(this.isRateCustom()){
      rate = this.inputCustomRate.value.replaceAll(/\./g,'').replace(/\,/, '.');
    } else {
      rate = this.rateElement.selectedOptions[0].dataset.rateValue;
    }
    const value = this.element.value.replaceAll(/\./g,'').replace(/\,/, '.');

    const res = parseFloat(value) / parseFloat(rate);
    this.usdElement.value = res;

    const event = new Event('input-price:re-init');
    this.usdElement.dispatchEvent(event);
  }

  isRateCustom(){
    if(!this.selectedInputRatesSource){ return false; }
    return this.selectedInputRatesSource.value === 'custom'
  }
  isInputOptionCustom(){
    if(!this.selectedInputOption){ return false; }
    return this.selectedInputOption.value === 'no_automatic_rates_adjustment'
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

  get selectedInputOption(){
    return this.inputOptionElements.filter((x) => {return x.checked})[0];
  }
  get inputOptionElements(){
    return Array.prototype.slice.call(
      this.element.closest('form').querySelectorAll('input[type="radio"][name="general_transaction[input_option]"]')
    );
  }

  get selectedInputRatesSource(){
    return this.inputRatesSourceElements.filter((x) => {return x.checked})[0];
  }
  get inputRatesSourceElements(){
    return Array.prototype.slice.call(
      this.element.closest('form').querySelectorAll('input[type="radio"][name="general_transaction[rates_source]"]')
    );
  }
  get inputCustomRate(){
    if(this._inputCustomRate){
      return this._inputCustomRate;
    }
    this._inputCustomRate = this.itemContainer.querySelector(
      'input[type="text"][name$="[rate]"]'
    );

    return this._inputCustomRate;
  }
  get itemContainer(){
    if(this._itemContainer){
      return this._itemContainer;
    }
    this._itemContainer = this.element;

    while(!this._itemContainer.classList.contains('js-item-container')){
      this._itemContainer = this._itemContainer.parentElement;
    }
    return this._itemContainer
  }
}
