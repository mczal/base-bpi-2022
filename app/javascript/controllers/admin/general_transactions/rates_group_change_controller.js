import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.endOfPeriodRatesOptionsContainer = document.querySelector('.js-end-of-period-rates-options-container');
    this.endOfPeriodRatesOptionsMonth = this.endOfPeriodRatesOptionsContainer.querySelector('select[name="general_transaction[end_of_period_rates_options][month]"]');
    this.endOfPeriodRatesOptionsYear = this.endOfPeriodRatesOptionsContainer.querySelector('select[name="general_transaction[end_of_period_rates_options][year]"]');
  }

  handleChange(){
    if(this.element.value === 'end_of_period_rates'){
      this.endOfPeriodRatesOptionsContainer.classList.remove('d-none');
      this.endOfPeriodRatesOptionsMonth.removeAttribute('disabled');
      this.endOfPeriodRatesOptionsYear.removeAttribute('disabled');
    }

    if(this.element.value === 'fixed_rates'){
      this.endOfPeriodRatesOptionsContainer.classList.add('d-none');
      this.endOfPeriodRatesOptionsMonth.setAttribute('disabled', 'disabled');
      this.endOfPeriodRatesOptionsYear.setAttribute('disabled', 'disabled');
    }
  }
}
