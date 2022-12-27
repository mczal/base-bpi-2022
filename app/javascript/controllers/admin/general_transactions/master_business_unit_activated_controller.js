import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.inputElements = Array.prototype.slice.call(
      this.businessUnitContainer.querySelectorAll('input,select')
    );

    // this.accountCode = this.itemContainer.querySelector('select[name="general_transaction[general_transaction_lines_attributes][][code]"]');
    this.accountCode = this.itemContainer.querySelector('select[name^="general_transaction[general_transaction_lines_attributes]"][name*="code"]');

    this.mbu = this.itemContainer.querySelector('.mbu');
    this.mbul = this.itemContainer.querySelector('.mbul');
    this.mbuar = this.itemContainer.querySelector('.mbuar');
    this.mbuact = this.itemContainer.querySelector('.mbuact');
    this.mbuaccount = this.itemContainer.querySelector('.mbuaccount');
  }

  handleChange(e){
    if(!this.accountCode.reportValidity()){
      this.element.checked = !this.element.checked;
      return;
    }

    if(this.element.checked){
      this.applyAccountToMbuaccount();
      this.showBusinessUnit();
    } else {
      this.revertAllMbu();
      this.hideBusinessUnit();
    }
  }

  applyAccountToMbuaccount(){
    this.mbuaccount.innerHTML = ` ${this.accountCode.value}`;
  }
  revertAllMbu(){
    this.mbu.innerHTML = " _";
    this.mbul.innerHTML = " _ _";
    this.mbuar.innerHTML = " _ _ _ _ _";
    this.mbuact.innerHTML = " _ _ _ _";
    this.mbuaccount.innerHTML = " _ _ _ _";

    this.inputElements.forEach((element) => {
      if(element.tagName === 'INPUT'){
        element.checked = false;
      } else if(element.tagName === 'SELECT') {
        $(element).val('').trigger('change');
      }
    });
  }

  showBusinessUnit(){
    this.businessUnitContainer.classList.remove('d-none');
    this.inputElements.forEach((element) => {
      element.removeAttribute('readonly');
    });
  }
  hideBusinessUnit(){
    this.businessUnitContainer.classList.add('d-none');
    this.inputElements.forEach((element) => {
      element.setAttribute('readonly', 'readonly');
    });
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

  get businessUnitContainer(){
    if(this._businessUnitContainer){
      return this._businessUnitContainer;
    }

    let res = this.element;
    while(!res.classList.contains('js-item-container')){
      res = res.parentElement;
    }

    this._businessUnitContainer = res.querySelector('.js-business-unit');
    return this._businessUnitContainer;
  }
}
