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
      this.setAttributeToRequired();

      // this.element.setAttribute('required', 'required');
      this.requiredMark.classList.remove('d-none');
      return;
    }

    this.unsetAttributeToRequired();
    // this.element.removeAttribute('required');
    this.requiredMark.classList.add('d-none');
  }

  bindChange(){
    this.field.addEventListener('change', this.synchronize.bind(this));
  }

  setAttributeToRequired(){
    this.inputElements.forEach(x => {
      x.setAttribute('required','required');
      x.removeAttribute('disabled');
    });
  }
  unsetAttributeToRequired(){
    this.inputElements.forEach(x => {
      x.removeAttribute('required');
      x.checked = false;
      x.setAttribute('disabled','disabled');
    });
  }

  get inputElements(){
    if(this._inputElements){
      return this._inputElements;
    }
    this._inputElements = Array.prototype.slice.call(
      this.element.querySelectorAll(
        'input[name="invoice_direct_external[ppn_percentage]"],input[name="invoice_direct_external[ppn_group]"],input[name="invoice_direct_external[ppn_cost_group]"]'
      )
    );
    return this._inputElements;
  }

  get requiredMark(){
    if(this._requiredMark){
      return this._requiredMark;
    }
    this._requiredMark = this.element.querySelector('span.required');
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
