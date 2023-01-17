import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['id', 'bottomTreshold', 'upperTreshold'];

  initialize(){
    this.path = this.data.get('path');
  }

  save(){
    window.KTApp.blockPage();
    window.Ajax.post(this.path, this.ajaxOptions)
  }

  handleSuccess(responseText){
  }
  handleFail(responseText){
    console.error('[ERROR]', responseText);
  }
  handleDone(){
    window.location.reload();
  }

  get ajaxOptions(){
    return {
      data: JSON.stringify(this.payload),
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

  get payload(){
    return {
      approval_configuration: [
        {
          id: this.idTarget.value,
          bottom_treshold: this.bottomTresholdTarget.value,
          upper_treshold: this.upperTresholdTarget.value,
        }
      ]
    }
  }
}
