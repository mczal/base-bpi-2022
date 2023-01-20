import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
  }

  connect(){
    window.KTApp.block(this.element);
    const path = this.path
    window.Ajax.get(path, this.ajaxOptions);
  }

  handleSuccess(responseText){
    this.element.outerHTML = responseText;
  }

  handleFail(responseText){
    console.error('[ERROR]');
  }

  handleDone(){
    window.KTApp.unblock(this.element);
  }

  get ajaxOptions(){
    return {
      onSuccess: this.handleSuccess.bind(this),
      onFail: this.handleFail.bind(this),
      onDone: this.handleDone.bind(this)
    };
  }
}
