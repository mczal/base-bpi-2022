import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.url = this.data.get('url');
  }

  handleClick(e){
    this.element.setAttribute('disabled','disabled');
    window.Ajax.post(this.url, this.ajaxOptions);
  }

  handleSuccess(responseText){
    window.Util.removeElement(this.containerElement);
    window.Util.removeElement(this.popoverElement);
  }
  handleFail(responseText){
    console.log('[ERROR]', responseText);
  }
  handleDone(){
  }

  get containerElement(){
    return this.element.closest('a');
  }
  get popoverElement(){
    return document.querySelector('.popover');
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
        }
      ],
      onSuccess: this.handleSuccess.bind(this),
      onFail: this.handleFail.bind(this),
      onDone: this.handleDone.bind(this)
    }
  }
}
