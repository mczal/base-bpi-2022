import { Controller } from 'stimulus';

export default class extends Controller {
  connect(){
    this.element.addEventListener('input-price:re-init', () => {
      this.replaceDotToComma();
      this.addThousandSeparator();
    });

    // this.addCommaIfNotExist();
    this.replaceDotToComma();
    this.addThousandSeparator();

    this.bindInputElement();
    this.bindFocusoutElement();
    this.bindFocusinElement();
    this.bindKeyupElement();
    // this.bindPasteElement();
  }

  replaceDotToComma(){
    let value = this.element.value;
    if(!value){
      return;
    }

    if(value.indexOf('.') > 0){
      value = `${value.replace('.', ',')}`;
      if(value.split(',')[1].length == 1){
        this.element.value = `${value}0`;
        return
      }
      this.element.value = value
      return;
    }

    this.element.value = `${value},00`;
  }

  addCommaIfNotExist(){
    const value = this.element.value;
    if(!value){
      return;
    }
    if(value.indexOf(',') > 0){
      return;
    }

    this.element.value = `${value},00`;
  }

  addThousandSeparator(){
    const value = this.element.value;
    if(value === ''){
      return;
    }

    let valueCommaToken = value.split(',')

    let valueBeforeComma = this.processValueBeforeComma(valueCommaToken[0]);
    let valueAfterComma = this.processValueAfterComma(valueCommaToken[1]);

    this.element.value = `${valueBeforeComma}${valueAfterComma}`;
    this.dispatchChangeEvent();
  }

  bindInputElement(){
    this.element.addEventListener('input', this.handleInputElement.bind(this));
  }

  bindFocusoutElement(){
    this.element.addEventListener('focusout', this.handleFocusoutElement.bind(this));
  }

  bindFocusinElement(){
    this.element.addEventListener('focusin', this.handleFocusinElement.bind(this));
  }

  bindKeyupElement(){
    this.element.addEventListener('keyup', this.handleKeyupElement.bind(this));
  }

  bindPasteElement(){
    this.element.addEventListener('paste', this.handlePasteElement.bind(this));
  }

  processValueBeforeComma(value){
    let valuesBeforeComma = this.removeSeparatorNumber(value);

    let tempLengthRunning = valuesBeforeComma.length;
    for(let i=0; tempLengthRunning > 3; i++){
      tempLengthRunning -= 3;
      valuesBeforeComma.splice(tempLengthRunning, 0, '.');
    }

    return valuesBeforeComma.join('');
  }

  processValueAfterComma(value){
    let result = value;

    if(result){
      return `,${result}`;
    }

    let currentValue = this.element.value;
    if(currentValue[currentValue.length-1] === ','){
      return ',';
    }

    return '';
  }

  removeSeparatorNumber(number){
    let result = [];

    let token = number.split('');
    for(let i=0; i<token.length; i++){
      if(token[i] === '.') {
        continue;
      }

      result.push(token[i]);
    }

    return result;
  }

  handleInputElement(e){
    if(e.inputType !== 'insertText'){
      return;
    }

    let allowedChar = [',', '.'];
    if(allowedChar.includes(e.data) || e.data.match(/[0-9]/)){
      this.addThousandSeparator();
      return;
    }

    let currentValue = this.element.value;
    this.element.value = currentValue.replace(e.data, '');
  }

  handleFocusoutElement(){
    let currentValue = this.element.value;
    if(currentValue === ''){
      this.element.value = '0,00';
      this.dispatchChangeEvent();
      return;
    }

    if(currentValue.includes(',') && currentValue[currentValue.length-1] !== ','){
      return;
    }

    if(currentValue[currentValue.length-1] === ','){
      this.element.value = `${currentValue}00`;
      this.dispatchChangeEvent();
      return;
    }

    this.element.value = `${currentValue},00`;
    this.dispatchChangeEvent();
  }

  handleKeyupElement(event){
    switch(event.keyCode){
      case 13:
        this.handleFocusoutElement();
        break;

      case 8:
        this.addThousandSeparator();
        break;

      case 46:
        this.addThousandSeparator();
        break;

      default:
        break;
    }
  }

  handleFocusinElement(){
    let currentValue = this.element.value;
    if(currentValue === '0,00'){
      this.element.value = '';
    }
  }

  handlePasteElement(e){
    e.preventDefault();
  }

  dispatchChangeEvent(){
    let newPrice = this.element.value;
    let eventName = 'order-total-price_price-component-change';
    let event = new CustomEvent(eventName, { detail: {
      id: this.id,
      price: newPrice,
      type: 'price-modification'
    }});

    window.dispatchEvent(event);
  }
}
