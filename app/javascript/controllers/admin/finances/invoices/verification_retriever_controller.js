import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  handleClick(e){
    if(!this.isValid()){
      return;
    }
    window.KTApp.blockPage();
    window.Ajax.post(this.path, this.ajaxOptions);
  }

  isValid(){
    return this.ppnCostGroupInput.reportValidity() &&
      this.pphIdInput.reportValidity() &&
      this.pphPercentageInput.reportValidity()
  }

  handleSuccess(responseText){
    this.verificationResultContainer.innerHTML = responseText;
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }
  handleDone(){
    window.KTApp.unblockPage();
  }

  get verificationResultContainer(){
    return this.form.querySelector('.js-verification-result-container');
  }

  get ajaxOptions(){
    return {
      onFail: this.handleFail.bind(this),
      onDone: this.handleDone.bind(this),
      onSuccess: this.handleSuccess.bind(this),
      data: JSON.stringify({
        pph_percentage: this.pphPercentageInput.value,
        pph_id: this.pphIdInput.value,
        fine: this.fineInput.value,
        ppn_cost_group: this.checkedPpnCostGroupInput.value,
      }),
      headers: [
        {
          key: 'Content-Type',
          value: 'application/json'
        },
        {
          key: 'X-CSRF-Token',
          value: window.Util.getCsrfToken()
        }
      ]
    }
  }

  get pphPercentageInput(){
    return this.form.querySelector('input[name="invoice[pph_percentage]"]');
  }
  get pphIdInput(){
    return this.form.querySelector('select[name="invoice[pph_id]"]');
  }
  get fineInput(){
    return this.form.querySelector('input[name="invoice[fine]"]');
  }
  get checkedPpnCostGroupInput(){
    return this.form.querySelector('input[name="invoice[ppn_cost_group]"]:checked');
  }
  get ppnCostGroupInput(){
    return this.form.querySelector('input[name="invoice[ppn_cost_group]"]');
  }

  get form(){
    if(this._form){
      return this._form;
    }

    this._form = this.element.closest('form');
    return this._form;
  }
}
