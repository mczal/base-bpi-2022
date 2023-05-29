import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.field = this.form.querySelector(`input[name="${this.data.get('fieldName')}"]:not([type="hidden"])`);
  }

  connect(){
    this.synchronize();
    this.bindChange();
  }

  synchronize(){
    if(this.field.checked){
      this.element.setAttribute('required', 'required');
      this.requiredMark.classList.remove('d-none');
      return;
    }

    this.element.removeAttribute('required');
    this.requiredMark.classList.add('d-none');
  }

  bindChange(){
    this.field.addEventListener('change', this.synchronize.bind(this));
  }

  get requiredMark(){
    if(this._requiredMark){
      return this._requiredMark;
    }
    this._requiredMark = this.element.previousElementSibling.querySelector('span.required');
    return this._requiredMark;
  }

  get form(){
    if(this._form){
      return this._form;
    }
    this._form = this.element.closest('form');
    return this._form;
  }
}
