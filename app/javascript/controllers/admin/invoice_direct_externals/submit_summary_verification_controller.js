import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){}
  connect(){}

  handleSubmit(e){
    if(this.isFakturPajakComplexInputValid()){
      return;
    }
    e.preventDefault();
    window.Flash.show('danger', "Faktur Pajak Harus Diisi!");
    this.teardown();
  }

  isFakturPajakComplexInputValid(){
    const checkField = this.element.querySelector('input[type="checkbox"][name="invoice_direct_external[faktur_pajak_checked]"]:not([type="hidden"])');
    if(!checkField.checked){
      return true;
    }

    if(this.isFakturPajakPngFilled()){
      return true;
    }
    if(this.isFakturPajakPdfFilled()){
      return true;
    }

    return false;
  }

  isFakturPajakPngFilled(){
    const png = this.element.querySelector('input[name="invoice_direct_external[faktur_pajak_attributes][png]"][type="hidden"]');
    if(png && png.value){
      return true;
    }
    if(this.element.querySelector('input[type="hidden"][name="faktur_pajak_uploaded"]')){
      return true;
    }

    return false
  }
  isFakturPajakPdfFilled(){
    const pdf = this.element.querySelector('input[name="invoice_direct_external[faktur_pajak_attributes][pdf]"][type="hidden"]');
    if(pdf && pdf.value){
      return true;
    }
    if(this.element.querySelector('input[type="hidden"][name="faktur_pajak_uploaded"]')){
      return true;
    }

    return false
  }

  teardown(){
    const submit = this.element.querySelectorAll('input[type="submit"]');
    submit.forEach(x => {
      x.removeAttribute('disabled');
      x.removeAttribute('data-disable-with');
    });
  }
}
