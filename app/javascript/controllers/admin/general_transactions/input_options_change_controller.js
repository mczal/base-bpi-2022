import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
  }

  handleChange(){
    if(this.element.value === 'idr'){
      this.usdInputElements.forEach((element) => {
        element.setAttribute('readonly','readonly');
        element.classList.add('form-control-solid');
      })
      this.idrInputElements.forEach((element) => {
        element.removeAttribute('readonly');
        element.classList.remove('form-control-solid');
      })
    }
    if(this.element.value === 'usd'){
      this.idrInputElements.forEach((element) => {
        element.setAttribute('readonly','readonly');
        element.classList.add('form-control-solid');
      })
      this.usdInputElements.forEach((element) => {
        element.removeAttribute('readonly');
        element.classList.remove('form-control-solid');
      })
    }
    if(this.element.value === 'no_automatic_rates_adjustment'){
      this.idrInputElements.forEach((element) => {
        element.removeAttribute('readonly');
        element.classList.remove('form-control-solid');
      })
      this.usdInputElements.forEach((element) => {
        element.removeAttribute('readonly');
        element.classList.remove('form-control-solid');
      })
    }
  }

  get usdInputElements(){
    return Array.prototype.slice.call(
      document.querySelectorAll('input[name*="price_usd"]')
    );
  }

  get idrInputElements(){
    return Array.prototype.slice.call(
      document.querySelectorAll('input[name*="price_idr"]')
    );
  }
}
