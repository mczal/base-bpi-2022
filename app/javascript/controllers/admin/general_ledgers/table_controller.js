import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
    this.dateElement = $('#kt_dashboard_datepicker_custom');
    this.date = this.dateElement.val();
  }

  connect(){
    window.KTApp.block(this.element);
    window.Ajax.post(this.path, this.ajaxOptions);

    $('#kt_dashboard_datepicker_custom').on('change', function(e) {
      this.date = this.dateElement.val();
      window.KTApp.block(this.element);
      window.Ajax.post(this.path, this.ajaxOptions);
    }.bind(this));
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
      data: JSON.stringify({date: this.date}),
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
