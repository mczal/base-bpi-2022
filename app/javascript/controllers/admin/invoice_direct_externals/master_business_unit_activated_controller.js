import MasterBusinessUnitActivatedController from 'controllers/admin/general_transactions/master_business_unit_activated_controller';

export default class extends MasterBusinessUnitActivatedController {
  initialize(){
    super.initialize();
    this.accountCode = this.itemContainer.querySelector('select[name="invoice_direct_external[cost_center_id]"]');
  }

  applyAccountToMbuaccount(){
    // this.mbuaccount.innerHTML = ` ${this.accountCode.value}`;
    const selectedCode = this.accountCode.selectedOptions[0].dataset.code;
    this.mbuaccount.innerHTML = ` ${selectedCode}`;
  }
}
