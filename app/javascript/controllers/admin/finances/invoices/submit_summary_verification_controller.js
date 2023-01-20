import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
  }

  handleSubmit(e){
    e.preventDefault();
    this.adaptInput();
    // this.showSummary();
  }

  showSummary(){
    debugger;
  }

  adaptInput(){
    this.element.insertAdjacentHTML('beforeend', `
      <input type="hidden" name="submit_button" value="${this.activedElement.value}" />
    `);
  }

  get activedElement(){
    return document.activeElement;
  }
}
