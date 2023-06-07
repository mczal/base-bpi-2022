import ScannerController from 'controllers/admin/invoices/faktur_pajak/scanner_controller';

export default class extends ScannerController {
  get inputPng(){
    return this.element.querySelector('input[type="hidden"][name="invoice_direct_external[faktur_pajak_attributes][png]"]');
  }
  get inputPdf(){
    return this.element.querySelector('input[type="hidden"][name="invoice_direct_external[faktur_pajak_attributes][pdf]"]');
  }
}
