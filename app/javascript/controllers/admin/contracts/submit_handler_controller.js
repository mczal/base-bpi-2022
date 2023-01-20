import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  handleSubmit(e){
    e.preventDefault();

    this.element.insertAdjacentHTML('beforeend', `
      <input type="hidden" name="submit_button" value="${this.activedElement.value}" />
    `);
    this.element.submit();
  }

  get activedElement(){
    return document.activeElement;
  }
}
