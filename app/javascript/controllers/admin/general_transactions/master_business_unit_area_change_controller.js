import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.mbuar = this.itemContainer.querySelector('.mbuar');
  }

  connect(){
    $(this.element).on('select2:select', function(e){
      this.mbuar.innerHTML = ` ${this.element.selectedOptions[0].dataset.code}`;
    }.bind(this));
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
