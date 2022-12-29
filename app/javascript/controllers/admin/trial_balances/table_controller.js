import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  connect(){
    window.KTApp.block(this.element);
    window.Ajax.post(this.path, this.ajaxOptions);
  }

  handleSuccess(responseText){
    this.element.innerHTML = responseText;
  }
  handleDone(){
    window.KTApp.unblock(this.element);
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }

  get ajaxOptions(){
    return {
      headers: [
        {
          key: 'Content-Type',
          value: 'application/json'
        },
        {
          key: 'X-CSRF-Token',
          value: window.Util.getCsrfToken()
        },
      ],
      onFail: this.handleFail.bind(this),
      onDone: this.handleDone.bind(this),
      onSuccess: this.handleSuccess.bind(this),
    };
  }
}
