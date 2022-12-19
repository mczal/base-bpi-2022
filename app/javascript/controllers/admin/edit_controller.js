import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  handleClick(e){
    window.KTApp.blockPage();
    window.Ajax.post(this.path, this.ajaxOptions);
  }
  handleSuccess(responseText){
    this.targetElement.innerHTML = responseText;
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }
  handleDone(){
    window.KTApp.unblockPage();
  }

  get targetElement(){
    if(this._targetElement){
      return this._targetElement;
    }

    this._targetElement = document.querySelector('#Edit .js-modal-content');
    return this._targetElement;
  }

  get ajaxOptions(){
    return {
      onSuccess: this.handleSuccess.bind(this),
      onFail: this.handleFail.bind(this),
      onDone: this.handleDone.bind(this),
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
}

