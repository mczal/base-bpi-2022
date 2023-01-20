import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  connect(){
    $(this.contractInputElement).on('select2:select', this.handleChange.bind(this));
  }

  handleChange(e){
    const path = this.path.replace(/\-1/, this.contractInputElement.value);
    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions);
  }

  handleSuccess(responseText){
    this.element.innerHTML = responseText;
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

  get contractInputElement(){
    if(this._contractInputElement){
      return this._contractInputElement;
    }

    this._contractInputElement = document.querySelector('select[name="ba[contract_id]"]')
    return this._contractInputElement;
  }
}
