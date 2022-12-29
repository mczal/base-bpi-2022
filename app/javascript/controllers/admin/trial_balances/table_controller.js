import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
    this.date = $('#kt_dashboard_daterangepicker_custom');

    this.startDate = this.date.data('startDate').format('DD/MM/YYYY');
    this.endDate = this.date.data('endDate').format('DD/MM/YYYY');
  }

  connect(){
    window.KTApp.block(this.element);
    window.Ajax.post(this.path, this.ajaxOptions);

    $('#kt_dashboard_daterangepicker_custom').on('apply.daterangepicker', function(ev, picker) {
      this.startDate = picker.startDate.format("D/M/Y");
      this.endDate = picker.endDate.format("D/M/Y");
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
      data: JSON.stringify({daterange: `${this.startDate}-${this.endDate}`}),
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
