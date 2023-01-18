import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
    this.dateElement = $('#kt_dashboard_datepicker_custom');
    this.date = this.dateElement.val();

    this.filter = document.querySelector('[data-controller="admin--index-filter"]');
    this.filterTriggerer = this.filter.querySelector('[data-admin--index-filter-target="filterTriggerer"]');
  }

  connect(){
    window.KTApp.block(this.element);
    window.Ajax.post(this.path, this.ajaxOptions);

    this.bindDateChange();
    this.bindFilter();
  }

  bindFilter(){
    this.filterTriggerer.addEventListener('click', (e) => {
      window.KTApp.block(this.element);

      const inputs = this.filter.querySelectorAll('input,select');
      for(let i=0 ;i<inputs.length; i++){
        if(inputs[i].type === 'radio'){
          if(inputs[i].checked){
            this[inputs[i].name] = inputs[i].value;
          }
        } else if(inputs[i].tagName === 'SELECT'){
          const selectedOption = inputs[i].selectedOptions[0]
          if(selectedOption){
            this[inputs[i].name] = selectedOption.value;
          }
        } else {
          this[inputs[i].name] = inputs[i].value;
        }
      }


      window.Ajax.post(this.path, this.ajaxOptions);
      this.filter.click();
    });
  }

  bindDateChange(){
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

  get payload(){
    return {
      date: this.date,
      location: this.location
    };
  }

  get ajaxOptions(){
    return {
      data: JSON.stringify(this.payload),
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
