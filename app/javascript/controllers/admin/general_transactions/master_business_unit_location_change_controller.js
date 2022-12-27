import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.mbul = this.itemContainer.querySelector('.mbul');
  }

  handleChange(){
    this.mbul.innerHTML = ` ${this.element.dataset.code}`;
  }

  get itemContainer(){
    if(this._itemContainer){
      return this._itemContainer;
    }

    let result = this.element;
    while(!result.classList.contains('js-item-container')){
      result = result.parentElement;
    }

    this._itemContainer = result;
    return this._itemContainer;
  }
}
