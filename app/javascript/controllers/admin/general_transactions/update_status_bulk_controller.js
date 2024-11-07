import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.datatableElement = document.querySelector('#kt_datatable');
    this.path = this.data.get('path');

    this.filter = {};

    this.ids = [];
    this.count = 0;
    this.selectedAllRows = false;
  }

  connect(){
    this.datatableElement.addEventListener(
      'datatable:checkbox-updated',
      this.handleCheckboxUpdated.bind(this)
    );

    $(this.datatableElement).on('datatable-on-ajax-done',(e) => {
      this.filters = {};
      if(!window.generalTransactionDatatable){
        return;
      }

      this.assignFilters(window.generalTransactionDatatable.getDataSourceParam());
    })
  }

  assignFilters(sourceParam){
    if(sourceParam.date){
      this.filter.date = sourceParam.date
    }
    if(sourceParam.location){
      this.filter.location = sourceParam.location
    }
    if(sourceParam.number_evidence){
      this.filter.number_evidence = sourceParam.number_evidence
    }
    if(sourceParam.query && sourceParam.query.search){
      this.filter.querySearch = sourceParam.query.search
    }
  }

  handleCheckboxUpdated(e){
    this.ids = e.detail.ids;
    this.count = e.detail.count;
    this.selectedAllRows = e.detail.selectedAllRows;
  }

  approve(e){
    window.KTApp.blockPage();
    window.Ajax.post(this.path, this.ajaxOptions());
  }

  payload(){
    this.filter.ids = this.ids;
    this.filter.count = this.count;
    this.filter.selectedAllRows= this.selectedAllRows;
    return JSON.stringify(this.filter);
  }

  handleSuccess(responseText){
    window.generalTransactionDatatable.reload();
  }
  handleFail(responseText){
    console.error('[ERROR]',responseText);
  }
  handleDone(){
    window.KTApp.unblockPage();
  }

  ajaxOptions(){
    return {
      data: this.payload(),
      onDone: this.handleDone.bind(this),
      onFail: this.handleFail.bind(this),
      onSuccess: this.handleSuccess.bind(this),
      headers: [
        {
          key: 'X-CSRF-Token',
          value: window.Util.getCsrfToken()
        },
        {
          key: 'Content-Type',
          value: 'application/json'
        },
      ]
    }
  }
}
