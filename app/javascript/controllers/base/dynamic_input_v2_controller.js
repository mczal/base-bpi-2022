import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [ 'element', 'input', 'markdownIndex' ];

  initialize(){
    this.firstClonedNode = this.element.querySelector('.js-item-container').cloneNode(true);
    // this.clonedItem = this.element.querySelector('.js-item-container').cloneNode(true);
    // this.clonedItem;
  }

  get clonedItem(){
    if(this._cloned_item){
      return this._cloned_item;
    }

    let targetContainer = this.element.querySelector('.js-item-container')
    if(targetContainer){
      this._cloned_item = targetContainer.cloneNode(true);
      return this._cloned_item;
    }

    this._cloned_item = this.firstClonedNode;
    return this._cloned_item;
  }

  add(){
    const node = this.clonedItem.cloneNode(true);
    this.prepareNode(node);

    this.element.insertAdjacentElement('beforeend', node);
    this.reassignIndex();

    const event = new Event('base--dynamic-input-v2:add');
    this.element.dispatchEvent(event);
  }

  remove(e){
    // if(this.element.querySelectorAll('.js-item-container').length <= 1){
      // return;
    // }

    let selectedNode = e.srcElement;
    while(!selectedNode.classList.contains('js-item-container')){
      selectedNode = selectedNode.parentElement;
    }

    window.Util.removeElement(selectedNode);
    this.reassignIndex();
  }

  prepareNode(node){
    const inputs = Array.prototype.slice.call(node.querySelectorAll('input:not([type=hidden]),textarea'));
    const selects = Array.prototype.slice.call(node.querySelectorAll('select'));

    inputs.forEach((x) => {x.value = null;});
    selects.forEach((x) => {
      x.value = null;
      if(x.nextElementSibling && x.nextElementSibling.tagName === 'SPAN' && x.nextElementSibling.classList.contains('select2-container')){
        window.Util.removeElement(x.nextElementSibling);
      }
      x.classList.remove('select2-hidden-accessible');
      x.removeAttribute('data-select2-id');
      x.setAttribute('id', `A-${window.Util.uuidv4()}`);

      Array.prototype.slice.call(x.querySelectorAll('option')).forEach((opt) => {
        opt.removeAttribute('data-select2-id');
      });
    });
  }

  reassignIndex(node){
    const items = this.element.querySelectorAll('.js-item-container');
    for(let i=0; i<items.length; i++){
      // No.
      const itemIndex = items[i].querySelector('.js-item-index');
      itemIndex.innerHTML = `${i+1}.`;
    }

    const allItems = this.modal.querySelectorAll('.js-item-container');
    for(let i=0; i<allItems.length; i++){
      // Index Matrices
      const inputs = Array.prototype.slice.call(allItems[i].querySelectorAll('input,textarea'));
      const selects = Array.prototype.slice.call(allItems[i].querySelectorAll('select'));

      inputs.forEach((x) => {
        x.name = x.name.replace(/\[\d+\]/, `[${i}]`);
      });
      selects.forEach((x) => {
        x.name = x.name.replace(/\[\d+\]/, `[${i}]`);
      });
    }
  }


  get modal(){
    if(this._modal){
      return this._modal;
    }
    this._modal = this.element;
    while(!this._modal.classList.contains('modal')){
      this._modal = this._modal.parentElement;
    }
    return this._modal;
  }
}

