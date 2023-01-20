import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  connect(){
    $(this.clientInputElement).on('select2:select', this.handleChange.bind(this));
  }

  handleChange(e){
    const path = this.path.replace(/\-1/, this.clientInputElement.value);
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

  get clientInputElement(){
    if(this._clientInputElement){
      return this._clientInputElement;
    }

    this._clientInputElement = document.querySelector('select[name="contract[client_id]"]')
    return this._clientInputElement;
  }
}
