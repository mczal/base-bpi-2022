import GetClientDetailController from 'controllers/admin/contracts/get_client_detail_controller';

export default class extends GetClientDetailController {
  get clientInputElement(){
    if(this._clientInputElement){
      return this._clientInputElement;
    }

    this._clientInputElement = document.querySelector('select[name="invoice_direct_external[client_id]"]')
    return this._clientInputElement;
  }
}
