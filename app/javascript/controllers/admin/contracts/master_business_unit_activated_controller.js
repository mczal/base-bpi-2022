import MasterBusinessUnitActivatedController from 'controllers/admin/general_transactions/master_business_unit_activated_controller';

export default class extends MasterBusinessUnitActivatedController {
  initialize(){
    super.initialize();
    this.accountCode = this.itemContainer.querySelector('select[name="contract[accrued_debit_id]"]');
  }

  applyAccountToMbuaccount(){
    // this.mbuaccount.innerHTML = ` ${this.accountCode.value}`;
    const selectedCode = this.accountCode.selectedOptions[0].dataset.code;
    this.mbuaccount.innerHTML = ` ${selectedCode}`;
  }
}
