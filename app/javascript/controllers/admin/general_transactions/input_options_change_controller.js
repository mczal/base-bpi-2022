import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.idrInputElements = Array.prototype.slice.call(
      document.querySelectorAll('input[name*="price_idr"]')
    );
    this.usdInputElements = Array.prototype.slice.call(
      document.querySelectorAll('input[name*="price_usd"]')
    );
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
  }
}
