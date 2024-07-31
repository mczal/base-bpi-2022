import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  connect(){
    this.bindEventDynamicInputAdd();
  }

  bindEventDynamicInputAdd(){
    this.baseDynamicInputV2Elements.forEach((x) => {
      x.addEventListener('base--dynamic-input-v2:add', this.handleEventDynamicInputAdd.bind(this));
    });
  }

  handleEventDynamicInputAdd(){
    const checkedElement = this.inputRatesSourceElements.filter((x) => {return x.checked})[0];
    this.adjustAttributeAndClass(checkedElement.value);
  }

  handleChange(){
    this.adjustAttributeAndClass(this.element.value);
  }

  adjustAttributeAndClass(value){
    if(value === 'custom'){
      this.inputSelectFixedRatesOption.removeAttribute('required')
      this.inputSelectFixedRatesOption.setAttribute('disabled','disabled')

      this.customRateContainers.forEach((x) => {
        x.classList.remove('d-none');
        const y = x.querySelector('input');
        y.removeAttribute('disabled');
        y.setAttribute('required', 'required');
      });
    } else {
      this.inputSelectFixedRatesOption.setAttribute('required','required')
      this.inputSelectFixedRatesOption.removeAttribute('disabled')

      this.customRateContainers.forEach((x) => {
        x.classList.add('d-none');
        const y = x.querySelector('input');
        y.setAttribute('disabled','disabled');
        y.removeAttribute('required');
      });
    }
  }

  get inputRatesSourceElements(){
    return Array.prototype.slice.call(
      this.element.closest('form').querySelectorAll('input[type="radio"][name="general_transaction[rates_source]"]')
    );
  }

  get inputSelectFixedRatesOption(){
    return this.element.closest('form').querySelector(
      'select[name="general_transaction[fixed_rates_options][id]"]'
    )
  }

  get customRateContainers(){
    return Array.prototype.slice.call(
      this.element.closest('form').querySelectorAll(
        '.js-custom-rate-container'
      )
    );
  }

  get baseDynamicInputV2Elements(){
    return Array.prototype.slice.call(
      this.element.closest('form').querySelectorAll('[data-controller="base--dynamic-input-v2"]')
    );
  }
}
