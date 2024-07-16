import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.paramContainer = this.element.querySelector('.js-param-container');
  }

  connect(){
    this.element.addEventListener('submit', this.handleSubmit.bind(this));
  }

  handleSubmit(e){
    e.preventDefault();

    this.injectFormData();
    this.element.submit();
  }

  injectFormData(){
    this.paramContainer.innerHTML = '';

    Object.keys(this.payload).filter((x) => {return !!x}).forEach((x) => {
      this.paramContainer.insertAdjacentHTML('beforeend', `
        <input type="hidden" name="${x}" value="${this.payload[x]}">
      `);
    });
  }

  get payload(){
    const result = {};
    const dataSourceParam = window.journalDatatable.getDataSourceParam();

    if(dataSourceParam.code){
      result['code'] = dataSourceParam.code;
    }
    if(dataSourceParam.date){
      result['date'] = dataSourceParam.date;
    }
    if(dataSourceParam.description){
      result['description'] = dataSourceParam.description;
    }
    if(dataSourceParam.location){
      result['location'] = dataSourceParam.location;
    }
    if(dataSourceParam.number_evidence){
      result['number_evidence'] = dataSourceParam.number_evidence;
    }
    if(dataSourceParam.query && dataSourceParam.query.search){
      result['search'] = dataSourceParam.query.search;
    }

    return result;
  }
}
