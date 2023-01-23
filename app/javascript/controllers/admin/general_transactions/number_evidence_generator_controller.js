import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['accountForNumberEvidence','resultForBni','resultForBj'];

  initialize(){
    this.path = this.data.get('path');
  }

  generateForBni(){
    if(!this.selectedLocation){
      this.locations[0].reportValidity();
      return;
    }
    if(!this.accountForNumberEvidenceTarget.value){
      return;
    }
    const path = this.path
      .replace(/\-1/, this.selectedLocation.value)
      .replace(/\-2/, 'cash')
      .replace(/\-3/, this.accountForNumberEvidenceTarget.value);

    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions);
  }
  copyForBni(){
    this.numberEvidence.value = this.resultForBniTarget.value;
  }
  generateForBj(){
    if(!this.selectedLocation){
      this.locations[0].reportValidity();
      return;
    }
    let path = this.path
      .replace(/\-1/, this.selectedLocation.value)
      .replace(/\-2/, 'cash')
    if(this.accountForNumberEvidenceTarget.value){
      path = path.replace(/\-3/, this.accountForNumberEvidenceTarget.value);
    }

    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions);
  }
  copyForBj(){
    this.numberEvidence.value = this.resultForBjTarget.value;
  }

  get numberEvidence(){
    if(this._numberEvidence){
      return this._numberEvidence;
    }
    this._numberEvidence = this.element
      .closest('form')
      .querySelector('input[name="general_transaction[number_evidence]"]');
    return this._numberEvidence;
  }
  get selectedLocation(){
    return this.locations.filter((x) => {return x.checked})[0]
  }
  get locations(){
    if(this._locations){
      return this._locations;
    }
    this._locations = Array.prototype.slice.call(
      this.element.closest('form').querySelectorAll('input[name="general_transaction[location]"]')
    );
    return this._locations
  }

  handleSuccess(responseText){
    const result = JSON.parse(responseText);
    this.resultForBniTarget.value = result.result_cash;
    this.resultForBjTarget.value = result.result_bj;
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }
  handleDone(){
    window.KTApp.unblockPage();
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
        }
      ]
    }
  }
}
